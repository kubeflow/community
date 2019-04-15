"""A script to create a plot of the number of issues in a project.

Uses GitHub's API v4 which uses graphql
https://developer.github.com/v4/

For more instructions see the the corresponding Jupyter notebook:
project_stats.ipynb
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

def run_query(query, headers): # A simple function to use requests.post to make the API call. Note the json= section.
  request = requests.post('https://api.github.com/graphql', json={'query': query}, headers=headers)
  if request.status_code == 200:
    return request.json()
  else:
    raise Exception("Query failed to run by returning code of {}. {}".format(request.status_code, query))

class ProjectStats(object):
  def __init__(self, project):
    self.query_template = None
    self.project = project

  def init_df(self, offset=0, size=300):
    """Initialize a dataframe of the specified size."""
    return pd.DataFrame({
        "time": [datetime.datetime.now()] * size,
        "delta": np.zeros(size),
        "label": [""] * size,
    }, index=offset + np.arange(size))

  def grow_df(self, df, offset=0, size=300):
    return pd.concat([df, self.init_df(offset, size)])

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
                                       columns=['label'], fill_value=0,
                                       aggfunc=np.sum)
    self.stats = self.stats.cumsum()
    self.stats = self.stats.rename(mapper={"delta": "open", "total_delta":"total"},
                                   axis='columns')

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
    projects(last:1 search:"{project}") {{
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

                          labels(last:15) {{
                              totalCount
                              edges {{
                                node {{
                                  name
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

        query = self.query_template.format(project=self.project,
                                           columns_cursor=columns_cursor_text,
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
          # Cards can contain pull requests and these may not have labels
          if not "labels" in c:
            continue

          labels_connections = c["labels"]

          if labels_connections["totalCount"] > 15:
            raise ValueError("Number of total labels exceeds the number "
                             "fetched; need to add pagination")

          labels = labels_connections["edges"]

          label_names = []

          for l in labels:
            label_names.append(l["node"]["name"])

          if not label_names:
            label_names.append("nolabels")

          num_entries = len(label_names) * 2
          if num_items + num_entries  > data.shape[0]:
            # Grow the dataframe
            data = self.grow_df(data, offset=data.shape[0])

          for f in ["createdAt", "closedAt"]:
            if not c[f]:
              continue

            delta = 1
            if f == "closedAt":
              delta = -1

            for l in label_names:
              if delta > 0:
                data["time"].at[num_items] = date_parser.parse(c["createdAt"])
              else:
                data["time"].at[num_items] = date_parser.parse(c["closedAt"])

              data["delta"].at[num_items] = delta
              data["label"].at[num_items] = l
              num_items += 1

    self.data = data[:num_items]


if __name__ == "__main__":
  c = ProjectStats()
  c.main()