// Label automation for Infrastructure Request issues (KEP-939).
// Invoked from .github/workflows/infra-activity.yml via actions/github-script.

const NEEDS_ALLOCATION = 'infra/needs-allocation';
const ALLOCATED = 'infra/allocated';
const TIMELINE_PREFIX = 'infra/timeline-';
const EXPIRED = `${TIMELINE_PREFIX}expired`;
// Ordered from longest to shortest remaining lease.
const BUCKETS = [120, 90, 60, 30];
const KEP_URL =
  'https://github.com/kubeflow/community/tree/master/proposals/939-oci-infrastructure-management';

const LABEL_DEFINITIONS = {
  [NEEDS_ALLOCATION]: { color: 'fbca04', description: 'Infra request awaiting review and provisioning (KEP-939)' },
  [ALLOCATED]: { color: '0e8a16', description: 'Infra provisioned and handed over to the PoC (KEP-939)' },
  [`${TIMELINE_PREFIX}120d`]: { color: 'c2e0c6', description: 'At most 120 days remaining on the infra lease' },
  [`${TIMELINE_PREFIX}90d`]: { color: 'bfd4f2', description: 'At most 90 days remaining on the infra lease' },
  [`${TIMELINE_PREFIX}60d`]: { color: 'fef2c0', description: 'At most 60 days remaining on the infra lease' },
  [`${TIMELINE_PREFIX}30d`]: { color: 'f9d0c4', description: 'At most 30 days remaining on the infra lease' },
  [EXPIRED]: { color: 'b60205', description: 'Infra lease elapsed; renewal or decommissioning required' },
};

const DAY_MS = 24 * 60 * 60 * 1000;

function bucketLabel(days) {
  return `${TIMELINE_PREFIX}${days}d`;
}

function timelineLabelsOf(issue) {
  return issue.labels
    .map((l) => (typeof l === 'string' ? l : l.name))
    .filter((name) => name.startsWith(TIMELINE_PREFIX));
}

function bucketDays(label) {
  const match = /^infra\/timeline-(\d+)d$/.exec(label);
  return match ? Number(match[1]) : null;
}

// Smallest bucket that still covers `remaining` days; expired when none remain.
function targetLabel(remaining) {
  if (remaining <= 0) return EXPIRED;
  const fitting = [...BUCKETS].reverse().find((b) => b >= remaining);
  return fitting ? bucketLabel(fitting) : bucketLabel(BUCKETS[0]);
}

// GitHub handles mentioned in the PoC field: the issue form renders each field
// as "### <label>\n\n<value>", and the PoC field is the first one.
function pocMentions(issue) {
  const body = issue.body || '';
  const firstField = body.split(/(?:^|\n)### /)[1] || '';
  const handles = new Set(firstField.match(/@[A-Za-z0-9-]+/g) || []);
  handles.add(`@${issue.user.login}`);
  return [...handles].join(' ');
}

async function removeLabel(github, context, issueNumber, name) {
  try {
    await github.rest.issues.removeLabel({ ...context.repo, issue_number: issueNumber, name });
  } catch (error) {
    if (error.status !== 404) throw error; // already gone
  }
}

// --- issues: labeled -------------------------------------------------------

async function syncLabels({ github, context, core }) {
  const issue = context.payload.issue;
  const added = context.payload.label.name;

  if (added.startsWith(TIMELINE_PREFIX)) {
    for (const stale of timelineLabelsOf(issue).filter((l) => l !== added)) {
      core.info(`#${issue.number}: removing ${stale} (superseded by ${added})`);
      await removeLabel(github, context, issue.number, stale);
    }
  }

  if (added === ALLOCATED) {
    core.info(`#${issue.number}: removing ${NEEDS_ALLOCATION} (now ${ALLOCATED})`);
    await removeLabel(github, context, issue.number, NEEDS_ALLOCATION);
  }
}

// --- schedule / workflow_dispatch -------------------------------------------

async function ensureLabels({ github, context, core }) {
  for (const [name, { color, description }] of Object.entries(LABEL_DEFINITIONS)) {
    try {
      await github.rest.issues.createLabel({ ...context.repo, name, color, description });
      core.info(`Created label ${name}`);
    } catch (error) {
      if (error.status !== 422) throw error; // 422: already exists
    }
  }
}

// When was the given label most recently applied to the issue?
async function labelAppliedAt(github, context, issue, label) {
  const events = await github.paginate(github.rest.issues.listEvents, {
    ...context.repo,
    issue_number: issue.number,
    per_page: 100,
  });
  const applied = events
    .filter((e) => e.event === 'labeled' && e.label && e.label.name === label)
    .map((e) => new Date(e.created_at))
    .sort((a, b) => b - a)[0];
  return applied || new Date(issue.created_at);
}

function reminderComment(issue, from, to) {
  const poc = pocMentions(issue);
  const lines = [];
  if (to === EXPIRED) {
    const admins = (process.env.INFRA_ADMINS || '').trim();
    lines.push(`${poc} the lease for this infrastructure has **expired** (\`${from}\` → \`${to}\`).`);
    lines.push('');
    lines.push('Per [KEP-939](' + KEP_URL + '), resources are decommissioned once the lease ends unless an extension is requested and approved. To extend, comment here with the requested new duration so an admin can approve and apply the new timeline label.');
    if (admins) {
      lines.push('');
      lines.push(`${admins} please run the renewal audit or decommission the resources via Terraform.`);
    }
  } else {
    const remaining = bucketDays(to);
    lines.push(`${poc} heads-up: this infrastructure lease now has at most **${remaining} days** remaining (\`${from}\` → \`${to}\`).`);
    lines.push('');
    lines.push('If you need the resources beyond the current lease, request an extension in this issue before it expires. See [KEP-939](' + KEP_URL + ') for the process.');
  }
  lines.push('');
  lines.push('_This comment was posted automatically by the infra-activity workflow._');
  return lines.join('\n');
}

async function timelineCountdown({ github, context, core }) {
  const issues = await github.paginate(github.rest.issues.listForRepo, {
    ...context.repo,
    state: 'open',
    labels: ALLOCATED,
    per_page: 100,
  });
  const now = new Date();
  let changed = 0;

  for (const issue of issues) {
    if (issue.pull_request) continue;

    const [current, ...extras] = timelineLabelsOf(issue);
    if (!current) {
      core.warning(`#${issue.number} is ${ALLOCATED} but has no ${TIMELINE_PREFIX}* label; skipping`);
      continue;
    }
    if (extras.length) {
      core.warning(`#${issue.number} has several timeline labels (${[current, ...extras].join(', ')}); using ${current}`);
    }
    const days = bucketDays(current);
    if (days === null) continue; // already expired

    const since = await labelAppliedAt(github, context, issue, current);
    const elapsed = Math.floor((now - since) / DAY_MS);
    const target = targetLabel(days - elapsed);
    if (target === current) {
      core.info(`#${issue.number}: ${current} applied ${elapsed}d ago; no change`);
      continue;
    }

    core.info(`#${issue.number}: ${current} → ${target} (${elapsed}d elapsed)`);
    await github.rest.issues.addLabels({ ...context.repo, issue_number: issue.number, labels: [target] });
    for (const stale of [current, ...extras]) {
      await removeLabel(github, context, issue.number, stale);
    }
    await github.rest.issues.createComment({
      ...context.repo,
      issue_number: issue.number,
      body: reminderComment(issue, current, target),
    });
    changed += 1;
  }

  core.info(`Checked ${issues.length} allocated issue(s); updated ${changed}`);
}

module.exports = { syncLabels, ensureLabels, timelineCountdown, targetLabel, pocMentions };
