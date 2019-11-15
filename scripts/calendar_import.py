"""
Imports meetings in 'calendar.yaml' to the Kubeflow Community Calendar
For modifications please refer to the Google Calendar Python API:
https://developers.google.com/resources/api-libraries/documentation/calendar/v3/python/latest/calendar_v3.events.html#insert

Requires the following packages: oauth2client, pyyaml, google-api-python-client

Uses a service account -- the calendar must be shared with the service account
email and given permission: "Make changes to events"

References:
  https://developers.google.com/calendar/quickstart/python
    * Shows the web app flow
  https://developers.google.com/calendar/auth
"""
from datetime import datetime
import fire
import logging
import os
import yaml
import googleapiclient.errors
from googleapiclient.discovery import build
from google_auth_oauthlib import flow
from google.auth.transport import requests
from oauth2client import service_account
from pathlib import Path
import pickle
import json

# The public address of the kubeflow.org calendar
CALENDAR_ID = 'kubeflow.org_7l5vnbn8suj2se10sen81d9428@group.calendar.google.com'

SCOPES = ['https://www.googleapis.com/auth/calendar.events']

class CalendarUpdater:
  """Class to update the calendar"""

  def sync(self, oauth_client_secret=None):
    """Sync the events in the YAML file to the calendar

    Args:
      oauth_client_secret: Path to the json file containing an OAuth client id
        for an OAuth application to use the Calendar API.
    """
    home = str(Path.home())
    config_dir = os.path.join(home, ".config", "kubeflow", "calendar_import")
    if not os.path.exists(config_dir):
      os.makedirs(config_dir)

    # File to store credentials
    credentials_file = os.path.join(config_dir, "token.pickle")

    # TODO(jlewi): Don't hardcode this
    if not oauth_client_secret:
      oauth_client_secret = os.path.join(home, "secrets",
                                         "kf-calendar.oauth_client.json")
      logging.info("Oauth_client_secret not set trying default: %s",
                   oauth_client_secret)

    # Since we are using the Google calendar API which isn't a Google Cloud API
    # we can't use Google Cloud Platform Default Application credentials.
    # There are two modes we want to support
    # 1. Running locally using a personal account
    # 2. Running in a cluster using a service account
    # TODO(jlewi): Can we use Workload Identity with the calendar API or do
    # we have to use a service account
    creds = None
    # The file token.pickle stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    if os.path.exists(credentials_file):
      with open(credentials_file, 'rb') as token:
        creds = pickle.load(token)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
      if creds and creds.expired and creds.refresh_token:
        creds.refresh(requests.Request())
      else:
        if os.environ.get("GOOGLE_APPLICATION_CREDENTIALS"):
          # TODO(jlewi): How do we obtain credentials with a service account?
          SERVICE_ACCOUNT_FILE = os.environ.get('GOOGLE_APPLICATION_CREDENTIALS')
          creds = service_account.ServiceAccountCredentials.from_json_keyfile_name(
            SERVICE_ACCOUNT_FILE, SCOPES)
        else:
          web_flow = flow.InstalledAppFlow.from_client_secrets_file(oauth_client_secret,
                                                                    SCOPES)
          creds = web_flow.run_local_server(port=0)

        # Save the credentials for the next run
        with open(credentials_file, 'wb') as token:
          pickle.dump(creds, token)

    service = build('calendar', 'v3', credentials=creds)

    this_file = __file__
    repo_root = os.path.abspath(os.path.join(os.path.dirname(this_file), ".."))
    cal_yaml = os.path.join(repo_root, "calendar.yaml")

    with open(cal_yaml) as cal:
      meetings = yaml.safe_load(cal)

      for meeting in meetings:
        date = meeting['date']
        time_start, time_end = meeting['time'].split('-')
        day_of_week = datetime.strptime("{} {}".format(date, time_start), '%m/%d/%Y %I:%M%p').strftime('%A').upper()[0:2]
        start_datetime = datetime.strptime("{} {}".format(date, time_start), '%m/%d/%Y %I:%M%p').strftime('%Y-%m-%dT%H:%M:%S%z')
        end_datetime = datetime.strptime("{} {}".format(date, time_end), '%m/%d/%Y %I:%M%p').strftime('%Y-%m-%dT%H:%M:%S%z')

        event = {
          'summary': meeting['name'],
          'id': meeting['id'],
          'location': meeting.get("video"),
          'description': meeting['description'],
                'start': {
                    'dateTime': start_datetime,
                    'timeZone': 'America/Los_Angeles',
                    },
                  'end': {
                    'dateTime': end_datetime,
                    'timeZone': 'America/Los_Angeles',
                    },
                  'guestsCanSeeOtherGuests': 'false',
                  'reminders': {
                    'useDefault': False,
                          'overrides': [
                        {'method': 'popup', 'minutes': 10},
                      ],
                      },
                  "creator": {
                          "displayName": "Kubeflow",
                      "email": "kubeflow-discuss@googlegroups.com",
                    },
                        "organizer": {
                      "displayName": meeting['organizer'],
                    },
        }


        if meeting.get("frequency"):
          rec = 'RRULE:FREQ={};BYDAY={}'.format(meeting['frequency'].upper(), day_of_week)

          if meeting['frequency'] == "bi-weekly":
            rec += ';INTERVAL=2'
            rec = rec.replace('BI-WEEKLY', 'WEEKLY')
          if meeting['frequency'] == "monthly":
            rec = rec.replace('WEEKLY', 'MONTHLY')

          event["recurrence"] = [rec]

        try:
          event = service.events().insert(calendarId=CALENDAR_ID, body=event).execute()
          logging.info("Event created: {}".format(event.get('htmlLink')))
        except googleapiclient.errors.HttpError as e:
          content = json.loads(e.content)

          if (content.get("error", {}).get("code") ==
              requests.requests.codes.CONFLICT):
            # It already exists so issue an update instead
            event = service.events().update(calendarId=CALENDAR_ID, eventId=meeting['id'],
                                            body=event).execute()
          logging.info("Event updated: {}".format(event.get('htmlLink')))
        except Exception as e:
          logging.error("Error occurred creating the event: ", e)

if __name__ == "__main__":
  logging.basicConfig(level=logging.INFO,
                      format=('%(levelname)s|%(asctime)s'
                                '|%(pathname)s|%(lineno)d| %(message)s'),
                        datefmt='%Y-%m-%dT%H:%M:%S',
                      )
  logging.getLogger().setLevel(logging.INFO)
  fire.Fire(CalendarUpdater)

