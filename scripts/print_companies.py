#!/usr/bin/python
#
# Print the names of all the companies listed in member organizations.yaml
import os
import yaml
if __name__ == "__main__":
  this_file = __file__
  repo_root = os.path.abspath(os.path.join(os.path.dirname(this_file),
                              ".."))
  org_file = os.path.join(repo_root, "member_organizations.yaml")
  with open(org_file) as hf:
    members = yaml.load(hf)
    
  names = [m["name"] for m in members]
  names.sort()
  
  print("Number of companies={0}".format(len(names)))
  print(", ".join(names))