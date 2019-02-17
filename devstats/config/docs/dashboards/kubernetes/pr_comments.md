<h1 id="kubernetes-dashboard">[[full_name]] PR comments dashboard</h1>
<p>Links:</p>
<ul>
<li>Metric <a href="https://github.com/cncf/devstats/blob/master/metrics/shared/pr_comments.sql" target="_blank">SQL file</a>.</li>
<li>TSDB <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/metrics.yaml" target="_blank">series definition</a>. Search for <code>pr_comments</code></li>
<li>Grafana dashboard <a href="https://github.com/cncf/devstats/blob/master/grafana/dashboards/kubernetes/pr-comments.json" target="_blank">JSON</a>.</li>
</ul>
<h1 id="description">Description</h1>
<ul>
<li>This dashboard shows median, 85th and 95th percentices of number of comments on PRs created in given periods.</li>
<li>Selecting period (for example week) means that dashboard will show number of comments created in those periods.</li>
<li>See <a href="https://github.com/cncf/devstats/blob/master/docs/periods.md" target="_blank">here</a> for more informations about periods.</li>
<li>We are skipping bots activity, see <a href="https://github.com/cncf/devstats/blob/master/docs/excluding_bots.md" target="_blank">excluding bots</a> for details.</li>
</ul>
