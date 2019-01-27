"""A script to identify Kubeflow issues that need attention.

Uses GitHub's API v4 which uses graphql
https://developer.github.com/v4/
"""
import argparse
import datetime
import json
import logging
import os
import requests

QUESTION_LABEL = "community/question"

def run_query(query, headers): # A simple function to use requests.post to make the API call. Note the json= section.
  request = requests.post('https://api.github.com/graphql', json={'query': query}, headers=headers)
  if request.status_code == 200:
    return request.json()
  else:
    raise Exception("Query failed to run by returning code of {}. {}".format(request.status_code, query))

def pretty_json(j):
  return json.dumps(j, indent=2, sort_keys=True)

def main():
  logging.getLogger().setLevel(logging.INFO)

  parser = argparse.ArgumentParser(
     description="Find issues that need attention.")

  # Create a gitor using an access token
  if not os.getenv("GITHUB_TOKEN"):
    logging.error("Environment variable GITHUB_TOKEN must be set")
    return

  query_template="""{{
    repository(owner:"kubeflow", name:"kubeflow") {{
    issues({issue_cursor} states:[OPEN]) {{
      totalCount
      edges {{
        node {{
          labels(last:10) {{
            totalCount
            edges {{
              node {{
                name
              }}
            }}
          }}
          comments(last:1) {{
            edges {{
              node {{
                author{{
                  login
                }}
                body
              }}
            }}
          }}
          title
          url
        }}
        cursor
      }}
      pageInfo {{
        endCursor
        hasNextPage
      }}
    }}
  }}
}}"""

  headers = {"Authorization": "Bearer {0}".format(os.getenv("GITHUB_TOKEN"))}

  issue_urls = set()
  cursor = None
  hasNextPage = True

  # Issues with no labels
  no_label_issues = set()

  # Community questions.
  question_issues = set()

  issues = []
  while hasNextPage:
    cursor_text = "first:100 "
    if cursor:
      cursor_text += "after:\"{0}\"".format(cursor)
    query = query_template.format(issue_cursor=cursor_text)
    result = run_query(query, headers=headers) # Execute the query

    cursor = result["data"]["repository"]["issues"]["pageInfo"].get("endCursor")
    hasNextPage = result["data"]["repository"]["issues"]["pageInfo"].get("hasNextPage", False)

    print(json.dumps(result, indent=2, sort_keys=True))

    issues.extend(result["data"]["repository"]["issues"]["edges"])
    for n in result["data"]["repository"]["issues"]["edges"]:
      issue_url = n["node"]["url"]
      issue_urls.add(issue_url)

      if n["node"]["labels"]["totalCount"] == 0:
        no_label_issues.add(issue_url)
      else:
        for l in n["node"]["labels"]["edges"]:
          name = l["node"]["name"]
          if name == QUESTION_LABEL:
            question_issues.add(issue_url)

  print("no_label_issues:\n")
  print("\n".join(no_label_issues))

  print("\n")
  print("question_issues:\n")
  print("\n".join(question_issues))


if __name__ == "__main__":
  main()