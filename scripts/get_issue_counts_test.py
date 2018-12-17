import datetime
import unittest
import get_issue_counts

class GetIssueCountsTest(unittest.TestCase):

  def test_stats(self):
    c = get_issue_counts.ComponentInfo("somearea")
    c.open_issues["priority/p0"] = 10
    c.add_issue("priority/p1", "open")
    c.add_issue("priority/p1", "open")
    c.add_issue("priority/p1", "closed")
    c.add_issue("priority/p2", "closed")

    date = datetime.datetime(2018, 10, 8, 13, 14, 20)
    stats = c.get_stats(date)

    expected = ["2018-10-08 13:14:20", 'somearea',
                10, 0, 2, 1, 0, 1, 0, 0, 0, 0, 14]
    self.assertItemsEqual(expected, stats)

if __name__ == "__main__":
  unittest.main()