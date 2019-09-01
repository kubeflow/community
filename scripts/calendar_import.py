#!/usr/bin/env python

# Imports meetings in 'calendar.yaml' to the Kubeflow Community Calendar
# For modifications please refer to the Google Calendar Python API:
# https://developers.google.com/resources/api-libraries/documentation/calendar/v3/python/latest/calendar_v3.events.html#insert

# Requires the following packages: oauth2client, pyyaml, google-api-python-client

# Uses a service account -- the calendar must be shared with the service account
# email and given permission: "Make changes to events"

from datetime import datetime
import logging
import os.path
import yaml
import googleapiclient.errors
from googleapiclient.discovery import build
from oauth2client.service_account import ServiceAccountCredentials

SERVICE_ACCOUNT_FILE = 'kubeflow_calendar_sa.json'
CALENDAR_ID = 'kubeflow@kubeflow.org'
SCOPES = ['https://www.googleapis.com/auth/calendar.events']

def main():
  logging.getLogger().setLevel(logging.INFO)
  creds = ServiceAccountCredentials.from_json_keyfile_name(SERVICE_ACCOUNT_FILE, SCOPES)
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
      rec = 'RRULE:FREQ={};BYDAY={}'.format(meeting['frequency'].upper(), day_of_week)

      if meeting['frequency'] == "bi-weekly":
          rec += ';INTERVAL=2'
          rec = rec.replace('BI-WEEKLY', 'WEEKLY')
      if meeting['frequency'] == "monthly":
          rec = rec.replace('WEEKLY', 'MONTHLY')

      event = {
        'summary': meeting['name'],
        'id': meeting['id'],
        'location': meeting['video'],
        'description': meeting['description'],
        'start': {
          'dateTime': start_datetime,
          'timeZone': 'America/Los_Angeles',
        },
        'end': {
          'dateTime': end_datetime,
          'timeZone': 'America/Los_Angeles',
        },
        'recurrence': [rec],
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

      try:
        event = service.events().insert(calendarId='CALENDAR_ID', body=event).execute()
        logging.info("Event created: {}".format(event.get('htmlLink')))
      except googleapiclient.errors.HttpError:
        event = service.events().update(calendarId='CALENDAR_ID', eventId=meeting['id'], body=event).execute()
        logging.info("Event updated: {}".format(event.get('htmlLink')))
      except Exception as e:
        logging.error("Error occurred creating the event: ", e)

if __name__ == '__main__':
    main()
