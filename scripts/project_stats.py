"""A script to create a plot of the number of issues in a project.

Uses GitHub's API v4 which uses graphql
https://developer.github.com/v4/

You will need an OAuth token to access GitHub with scopes:
   repo
   read:org

TODO(jlewi): We should fetch labels to identify priority of the issues.

"""
import argparse
import datetime
from dateutil import parser as date_parser
import json
import logging
import numpy as np
import os
import pandas as pd
import pprint
import requests

PROJECT_NAME = "0.5.0"

def run_query(query, headers): # A simple function to use requests.post to make the API call. Note the json= section.
  request = requests.post('https://api.github.com/graphql', json={'query': query}, headers=headers)
  if request.status_code == 200:
    return request.json()
  else:
    raise Exception("Query failed to run by returning code of {}. {}".format(request.status_code, query))

class ProjectStats(object):
  def __init__(self):
    self.query_template = None

  def init_df(self, size=300):
    """Initialize a dataframe of the specified size."""
    return pd.DataFrame({
        "time": [datetime.datetime.now()] * size,
        "delta": np.zeros(size),
        "priority": [""] * size,
    })

  def grow_df(self, df, size=300):
    return pd.concat([df, self.init_df(size)])

  def main(self):
    self.fetch_data()
    self.compute_stats()

  def compute_stats(self):
    # Compute a column to store total delta
    total_delta = np.max(np.row_stack([self.data["delta"].values,
                                       np.zeros(self.data.shape[0])]), axis=0)
    self.data["total_delta"] = total_delta

    self.stats = self.data.pivot_table(values=["delta", "total_delta"],
                                              index=['time'],
                                       columns=['priority'], fill_value=0)
    self.stats = self.stats.cumsum()

  def fetch_data(self):
    logging.getLogger().setLevel(logging.INFO)

    parser = argparse.ArgumentParser(
       description="Find issues that need attention.")

    # Create a gitor using an access token
    if not os.getenv("GITHUB_TOKEN"):
      logging.error("Environment variable GITHUB_TOKEN must be set")
      return

    # We need to look at ProjectCard and then ProjectCard item
    # https://developer.github.com/v4/object/projectcard/

    # TODO(jlewi): Take project as an argument
    self.query_template="""{{
    organization(login:"kubeflow") {{
    projects(last:1 search:"0.5.0") {{
      totalCount
      edges {{
        node {{
          name
          url
          columns(first:1 {columns_cursor}) {{
            totalCount
            pageInfo {{
              endCursor
              hasNextPage
            }}
            edges {{
              node {{
                cards(first:100 {cards_cursor}) {{
                  totalCount
                  pageInfo {{
                    endCursor
                    hasNextPage
                  }}
                  edges {{
                    node {{
                      content {{
                        __typename
                        ... on Issue {{
                          url
                          title
                          number
                          createdAt
                          closedAt
                        }}
                      }}
                    }}
                  }}
                }}
              }}
            }}
          }}
        }}
      }}
    }}
  }}
  }}
  """

    # Times at which issues were opened and closed
    opened = []
    closed = []

    headers = {"Authorization": "Bearer {0}".format(os.getenv("GITHUB_TOKEN"))}

    columns_cursor = None
    has_next_columns_page = True

    issues = []

    issue_numbers = []

    # Create a dataframe to store the results
    data = self.init_df()
    num_items = 0

    # We have to paginations to do
    # Over ccolumns and over cards
    while has_next_columns_page:
      columns_cursor_text = ""
      if columns_cursor:
        columns_cursor_text = "after:\"{0}\"".format(columns_cursor)

      has_next_cards_page = True
      cards_cursor = None

      while has_next_cards_page:
        cards_cursor_text = ""

        if cards_cursor:
          cards_cursor_text = "after:\"{0}\"".format(cards_cursor)

        query = self.query_template.format(columns_cursor=columns_cursor_text,
                                           cards_cursor=cards_cursor_text)

        result = run_query(query, headers=headers) # Execute the query
        projects_connections = result["data"]["organization"]["projects"]
        if projects_connections["totalCount"] != 1:
          raise ValueError("Total number of projects: Got {0} want 1".format(
                           projects_connections["totalCount"]))
        project = projects_connections["edges"][0]["node"]

        columns_connection = project["columns"]

        cards_connection = columns_connection["edges"][0]["node"]["cards"]

        cards_cursor = cards_connection["pageInfo"]["endCursor"]
        has_next_cards_page = cards_connection["pageInfo"]["hasNextPage"]

        # If we reached the end of cards for this column increment the columns_page
        # cards cursor
        if not has_next_cards_page:
          has_next_columns_page = columns_connection["pageInfo"]["hasNextPage"]
          columns_cursor = columns_connection["pageInfo"]["endCursor"]

        for e in cards_connection["edges"]:
          n = e["node"]
          c = n["content"]

          if not c:
            continue

          if num_items + 2  > data.shape[0]:
            # Grow the dataframe
            data = self.grow_df(data)

          if c["createdAt"]:
            data["time"][num_items] = date_parser.parse(c["createdAt"])
            data["delta"][num_items] = 1
            num_items += 1

          if c["closedAt"]:
            data["time"][num_items] = date_parser.parse(c["closedAt"])
            data["delta"][num_items] = -1
            num_items += 1

    self.data = data[:num_items]


if __name__ == "__main__":
  c = ProjectStats()
  c.main()