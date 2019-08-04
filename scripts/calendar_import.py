#!/usr/bin/env python

# Imports meetings in 'calendar.yaml' to the Kubeflow Community Calendar
# For modifications please refer to the Google Calendar Python API:
# https://developers.google.com/resources/api-libraries/documentation/calendar/v3/python/latest/calendar_v3.events.html#insert

from datetime import datetime
import os.path
import yaml
import googleapiclient.errors
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow

SCOPES = ['https://www.googleapis.com/auth/calendar.events']

def main():
  flow = InstalledAppFlow.from_client_secrets_file('credentials.json', SCOPES)
  creds = flow.run_local_server(port=0)
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
        event = service.events().insert(calendarId='primary', body=event).execute()
        print("Event created: {}".format(event.get('htmlLink')))
      except googleapiclient.errors.HttpError:
        event= service.events().update(calendarId='primary', eventId=meeting['id'], body=event).execute()
        print("Event updated: {}".format(event.get('htmlLink')))
      else:
        print("Error occurred creating the event")

if __name__ == '__main__':
    main()
