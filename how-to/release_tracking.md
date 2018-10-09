# Release Tracking

The current release tracking process is

1. Tag issues with the release label.

   * Any member in the org can tag an issue for release by doing

   ```
   /label area/X.Y.Z
   ```

1. The python script get_issue_counts.py dumpts to a CSV file number of current issues for 
   the specified release in each area

1. The CSV output of issue_counts.py can be imported into a Google sheet to track the stats

   * Each week we append the stats to this [Google Sheet](https://docs.google.com/spreadsheets/d/1Se5OcVGN5B3FJ5VPtICQmS5uxo1Y1dSrUL952Iy_qg8/edit#gid=0)