"""A script to compute number of issues in various components.

TODO(jlewi): We should break down issues by priority as well.
TODO(jlewi): Should we emit as csv and then import into spreadsheet?
"""
import argparse
import datetime
import github
import logging
import os

PRIORITIES = ["priority/p0", "priority/p1", "priority/p2", "priority/p3"]
NO_PRIORITY = "priority/none"

class ComponentInfo(object):

  def __init__(self, name, repo=""):
    self.label_name = name
    self.repo = repo
    self.total_issues = 0
    self.open_issues = {}
    self.closed_issues = {}

  @classmethod
  def get_field_names(cls):
    fields = ["date", "area"]

    all_priorites = []
    all_priorites.extend(PRIORITIES)
    all_priorites.append(NO_PRIORITY)

    for p in all_priorites:
      fields.append("{0} open".format(p))
      fields.append("{0} closed".format(p))

    fields.extend(["total_open", "total_closed", "total"])
    return fields

  def get_stats(self, date):
    fields = [date.strftime("%Y-%m-%d %H:%M:%S"), self.label_name]

    all_priorites = []
    all_priorites.extend(PRIORITIES)
    all_priorites.append(NO_PRIORITY)

    total_open = 0
    total_closed = 0
    for p in all_priorites:
      fields.append(self.open_issues.get(p, 0))
      fields.append(self.closed_issues.get(p, 0))
      total_open += self.open_issues.get(p, 0)
      total_closed += self.closed_issues.get(p, 0)

    total = total_open + total_closed
    fields.extend([total_open, total_closed, total])
    return fields

  def add_issue(self, priority, state):
    if state == "open":
      self.open_issues[priority]= self.open_issues.get(priority, 0) +1
    else:
      self.closed_issues[priority]= self.closed_issues.get(priority, 0) +1

def main():
  logging.getLogger().setLevel(logging.INFO)

  parser = argparse.ArgumentParser(
     description="Create a CSV file containing issue stats for the release.")

  parser.add_argument(
    "--output",
    default="",
    type=str,
    help="The file to write.")

  parser.add_argument(
    "--release_label",
    default="area/0.4.0",
    type=str,
    help="The label for the release")

  # Parse the args
  args = parser.parse_args()

  if not args.output:
    logging.error("You must provide a file to write to with --output")
    return

  if not args.release_label:
    logging.error("You must provide the label corresponding to the release "
                  "with --release_label")
    return

  # Create a gitor using an access token
  if not os.getenv("GITHUB_TOKEN"):
    logging.error("Environment variable GITHUB_TOKEN must be set")
    return
  g = github.Github(os.getenv("GITHUB_TOKEN"))

  # Then play with your Github objects:
  o = g.get_organization("kubeflow")

  release_label = args.release_label

  # TODO(jlewi): Should we just get all area labels programmatically
  # and just add mappings of label to repos for the ones that have it?
  components = [ComponentInfo("area/batch-predict", repo="batch-predict"),
                ComponentInfo("area/build-release"),
                ComponentInfo("area/chainer", repo="chainer"),
                ComponentInfo("area/docs", repo="website"),
                ComponentInfo("area/example", repo="examples"),
                ComponentInfo("area/front-end"),
                ComponentInfo("area/kfctl"),
                ComponentInfo("area/ksonnet"),
                ComponentInfo("area/jupyter"),
                ComponentInfo("area/horovod", "mpi-operator"),
                ComponentInfo("area/inference"),
                ComponentInfo("area/katib", repo="katib"),
                ComponentInfo("area/kubebench", repo="kubebench"),
                ComponentInfo("area/pytorch", repo="pytorch-operator"),
                ComponentInfo("area/seldon"),
                ComponentInfo("area/testing", repo="testing"),
                ComponentInfo("area/tfjob", repo="tfjob-operator"),]

  label_to_component = {}
  repo_to_component = {}
  for c in components:
    if c.label_name:
      label_to_component[c.label_name] = c
    if c.repo:
      repo_to_component[c.repo] = c

  for repo in o.get_repos():
    logging.info("Processing repo: %s", repo)
    name_to_label = {}
    for l in repo.get_labels():
      name_to_label[l.name] = l

    if not release_label in name_to_label:
      logging.warn("Repository %s is missing label %s", repo.name,
                   release_label)
      continue

    # Get all issues in this repo for this release
    issues = repo.get_issues(labels=[name_to_label[release_label]])
    for i in issues:
      # Get the labels for this issue
      labels = i.get_labels()

      # Loop over the issues looking for priority and components
      matched_components = []
      priority = NO_PRIORITY

      repo_is_match = False
      if repo.name in repo_to_component:
        repo_is_match = True
        matched_components.append(repo_to_component[repo.name])
      for l in labels:
        if not repo_is_match and (l.name in label_to_component.keys()):
          matched_components.append(label_to_component[l.name])
        if l.name in PRIORITIES:
          priority = l.name

      for c in matched_components:
        c.add_issue(priority, i.state)


  now = datetime.datetime.now()

  logging.info("Writing to file %s", args.output)
  with open(args.output, "w") as hf:
    for c in components:
      fields = ["{0}".format(f) for f in c.get_stats(now)]
      hf.write(",".join(fields))
      hf.write("\n")

if __name__ == "__main__":
  main()