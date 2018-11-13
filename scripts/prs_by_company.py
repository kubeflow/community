#!/usr/bin/python
#
# Product a CSV file containing number of PRs produced by each company.
# The input to the script is:
# 1) csv file containing number of PRs for different GitHub users. this_file
#    file is produced by exporting the data from devstats table
#    https://devstats.kubeflow.org/d/13/developers-table?orgId=1&var-period_name=v0.2.0%20-%20now&var-metric=prs&var-period=anno_1_now
# 2) Using gitdm to produce a json file containing users and their company.
import argparse
import csv
import logging
import json
import collections

import os
import yaml

if __name__ == "__main__":
  logging.getLogger().setLevel(logging.INFO)
  parser = argparse.ArgumentParser(
     description="Create a CSV file containing # of PRs by company.")

  parser.add_argument(
    "--users_file",
    default="",
    type=str,
    help="Json file containing information about committers.")

  parser.add_argument(
    "--prs_file",
    default="",
    type=str,
    help="The csv file containing # of PRs for different users.")

  parser.add_argument(
    "--output",
    default="",
    type=str,
    help="The file to write.")

  args = parser.parse_args()

  if not args.users_file:
    raise ValueError("--user_file must be specified.")

  if not args.prs_file:
    raise ValueError("--prs_file must be specified.")

  if not args.output:
    raise ValueError("--output must be specified.")

  with open(args.users_file) as hf:
    users = json.load(hf)

  # Build a dictionary mapping users to company
  login_to_company = {}
  for u in users:
    company = u.get("company")
    login = u.get("login")
    if not company:
      logging.info("Skipping user %s no company", login)
      continue
    company = company.lower().strip()
    company = company.strip("!")
    login_to_company[login] = company

  counts = collections.Counter()

  with open(args.prs_file) as hf:
    reader = csv.reader(hf, delimiter=";")
    # First line is headers
    reader.next()
    for row in reader:
      login = row[1]
      num_prs = int(row[2])
      company = login_to_company.get(login , "unknown")
      logging.info("User %s company %s # prs %s", login, company, num_prs)

      counts.update({company: num_prs})

  logging.info("Writing output to %s", args.output)
  with open(args.output, "w") as hf:
    for k, v in counts.iteritems():
      hf.write("{0}, {1}\n".format(k, v))
