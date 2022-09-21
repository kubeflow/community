"""
Imports meetings in 'caldendar/calendar.yaml' to the Kubeflow Community Calendar
For modifications please refer to the Google Calendar Python API:
https://developers.google.com/resources/api-libraries/documentation/calendar/v3/python/latest/calendar_v3.events.html#insert

Requires the following packages: oauth2client, pyyaml, google-api-python-client

Uses a service account -- the calendar must be shared with the service account
email and given permission: "Make changes to events"
  * Using a service account requires domain wide delegation in order to
    add attendees to meetings


References:
  https://developers.google.com/calendar/quickstart/python
    * Shows the web app flow
  https://developers.google.com/calendar/auth
"""
from datetime import datetime
from dateutil import parser as date_parser
import fire
import logging
import os
import subprocess
import time
import yaml
import googleapiclient.errors
from google.oauth2 import credentials
from google.api_core import exceptions as google_exceptions
from googleapiclient.discovery import build
from google_auth_oauthlib import flow
from google.cloud import secretmanager
from google.auth.transport import requests
from oauth2client import service_account
from pathlib import Path
import pickle
import json

# The public address of the kubeflow.org calendar
CALENDAR_ID = 'kubeflow.org_7l5vnbn8suj2se10sen81d9428@group.calendar.google.com'

SCOPES = ['https://www.googleapis.com/auth/calendar.events']

# The default GCP project and name of a secret in secret manager
# containing the oauth credentials for autobot@kubeflow.org.
DEFAULT_PROJECT = "kf-infra-gitops"
DEFAULT_SECRET = "autobot-at-kubeflow-oauth"

def update_meeting(service, meeting):
  date = meeting['date']
  time_start, time_end = meeting['time'].split('-')
  day_of_week = datetime.strptime("{} {}".format(date, time_start), '%m/%d/%Y %I:%M%p').strftime('%A').upper()[0:2]
  start_datetime = datetime.strptime("{} {}".format(date, time_start), '%m/%d/%Y %I:%M%p').strftime('%Y-%m-%dT%H:%M:%S%z')
  end_datetime = datetime.strptime("{} {}".format(date, time_end), '%m/%d/%Y %I:%M%p').strftime('%Y-%m-%dT%H:%M:%S%z')
  timezone = meeting.get("timezone", "America/Los_Angeles")

  event = {
    'summary': meeting['name'],
    'id': meeting['id'],
    'location': meeting.get("video"),
    'description': meeting['description'],
          'start': {
              'dateTime': start_datetime,
              'timeZone': timezone,
              },
            'end': {
              'dateTime': end_datetime,
              'timeZone': timezone,
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
    elif meeting['frequency'] == "every-4-weeks":
      rec += ';INTERVAL=4'
      rec = rec.replace('EVERY-4-WEEKS', 'WEEKLY')
    elif meeting['frequency'] == "monthly":
      # In monthly meetings start date defines week number
      # e.g. if start date is 09/09/2020 meetings are on every 2nd Wednesday
      start_datetime = datetime.strptime("{} {}".format(date, time_start), '%m/%d/%Y %I:%M%p')
      week_number = start_datetime.isocalendar()[1] - start_datetime.replace(day=1).isocalendar()[1] + 1
      rec = rec.replace(day_of_week, "{}{}".format(week_number, day_of_week))

    if meeting.get("until"):
      until_day = date_parser.parse(meeting.get("until"))
      until_time = date_parser.parse(end_datetime)
      until = datetime.combine(until_day.date(), until_time.time())
      # TODO(jlewi): Do we need to include a time zone correction?
      rec += ";UNTIL=" + until.strftime("%Y%m%dT%H%M%SZ")
    event["recurrence"] = [rec]

  if meeting.get("attendees"):
    event["attendees"] = meeting["attendees"]

  try:
    event = service.events().insert(calendarId=CALENDAR_ID, body=event).execute()
    logging.info("Created Event: {}".format(meeting['name'][:100]))
    logging.info(event.get('htmlLink'))
  except googleapiclient.errors.HttpError as e:
    content = json.loads(e.content)

    if (content.get("error", {}).get("code") ==
        requests.requests.codes.CONFLICT):
      # It already exists so issue an update instead
      event = service.events().update(calendarId=CALENDAR_ID, eventId=meeting['id'],
                                      body=event).execute()
      logging.info("Updated Event: {}".format(meeting['name'][:100]))
      logging.info(event.get('htmlLink'))
    else:
      logging.error("Exception occurred trying to insert event:\n%s",
                    content)
  except Exception as e:
    logging.error("Error occurred creating the event: ", e)

def get_user_credentials(oauth_client_secret=None,
                         credentials_file=None):
  """Obtain user credentials through the web flow.

  oauth_client_secret: Path to the json file containing an OAuth client id
        for an OAuth application to use the Calendar API. Only required if
        not using a service account

  credentials_file: Where to save the credentials

  credentials_secret:
  """
  home = str(Path.home())
  config_dir = os.path.join(home, ".config", "kubeflow", "calendar_import")
  if not os.path.exists(config_dir):
    os.makedirs(config_dir)

  # File to store credentials
  # Only used with the personal login flow.
  if not credentials_file:
    credentials_file = os.path.join(config_dir, "credentials.json")

  # TODO(jlewi): Don't hardcode this
  if not oauth_client_secret:
    raise ValueError("An oauth_client_secret is required when using end user "
                     "credentials")
  creds = None

  # The file token.pickle stores the user's access and refresh tokens, and is
  # created automatically when the authorization flow completes for the first
  # time.
  if os.path.exists(credentials_file):
    creds = credentials.Credentials.from_authorized_user_file(credentials_file)

  # If there are no (valid) credentials available, let the user log in.
  if not creds:
    web_flow = flow.InstalledAppFlow.from_client_secrets_file(oauth_client_secret,
                                                              SCOPES)
    creds = web_flow.run_local_server(port=0)

    # Save the credentials for the next run
    with open(credentials_file, 'w') as token:
      token.write(creds.to_json())

  if creds.expired and creds.refresh_token:
    creds.refresh(requests.Request())

  return creds

def _get_default_config():
  this_file = __file__
  repo_root = os.path.abspath(os.path.join(os.path.dirname(this_file), ".."))
  config = os.path.join(repo_root, "calendar/calendar.yaml")
  return config

def create_secret(client, project, secret):
  """
  Create a new secret with the given name. A secret is a logical wrapper
  around a collection of secret versions. Secret versions hold the actual
  secret material.
  """


  # Build the resource name of the parent project.
  parent = f"projects/{project}"

  # Create the secret.
  try:
    response = client.create_secret(
        request={
            "parent": parent,
              "secret_id": secret,
              "secret": {"replication": {"automatic": {}}},
          }
      )
  except google_exceptions.AlreadyExists:
    logging.info("Secret already exists")
    return

  # Print the new secret name.
  logging.info("Created secret: {response.name}")

def load_secret(client, project, secret):
  path = client.secret_path(project, secret)

  name = f"{path}/versions/latest"
  logging.info(f"Fetching secret {name}")
  # Access the secret version.
  response = client.access_secret_version(request={"name": name})

  # Print the secret payload.
  #
  # WARNING: Do not print the secret in a production environment - this
  # snippet is showing how to access the secret material.
  payload = response.payload.data.decode("UTF-8")
  return payload

def sync_calendar(config, creds):
  service = build('calendar', 'v3', credentials=creds)

  logging.info("Loading calendar data from %s", config)
  with open(config) as cal:
    meetings = yaml.safe_load(cal)

    for meeting in meetings:
      try:
        update_meeting(service, meeting)
      except Exception as e:
        logging.error("Could not update meeting %s; Error:\n%s",
                      meeting.get("id"), e)
        continue


class CalendarUpdater:
  """Class to update the calendar"""

  @staticmethod
  def sync(config=None, oauth_client_secret=None):
    """Sync the events in the YAML file to the calendar

    Args:
      config: Path to the YAML file containing the calendar data.
      oauth_client_secret: Path to the json file containing an OAuth client id
        for an OAuth application to use the Calendar API. Only required if
        not using a service account
    """
    # Since we are using the Google calendar API which isn't a Google Cloud API
    # we can't use Google Cloud Platform Default Application credentials.
    # There are two modes we want to support
    # 1. Running locally using a personal account
    # 2. Running in a cluster using a service account
    # TODO(jlewi): Can we use Workload Identity with the calendar API or do
    # we have to use a service account
    creds = None

    if config is None:
      config = _get_default_config()
      logging.info("config file not set resorting to default default")

    if os.environ.get("GOOGLE_APPLICATION_CREDENTIALS"):
      logging.info("GOOGLE_APPLICATION_CREDENTIALS is set using service "
                   "account")
      # TODO(jlewi): How do we obtain credentials with a service account?
      SERVICE_ACCOUNT_FILE = os.environ.get('GOOGLE_APPLICATION_CREDENTIALS')
      creds = service_account.ServiceAccountCredentials.from_json_keyfile_name(
        SERVICE_ACCOUNT_FILE, SCOPES)

      creds = creds.create_delegated("autobot@kubeflow.org")
    else:
      creds = get_user_credentials(oauth_client_secret=oauth_client_secret)

    sync_calendar(config, creds)

  @staticmethod
  def periodic_sync(config=None, project=DEFAULT_PROJECT,
                    secret=DEFAULT_SECRET, period_seconds=15):
    """Run the sync periodically at the desired interval.

    The sync only runs when the commit changes

    Args:
      config: Path to the YAML file containing the calendar config
      project: The GCP project containing the secret containing OAuth
        credentials for the bot account to run as
      secret: The name of the secret in GCP secret manager
      period_seconds: How frequently to check for changes to the file.
        This should be pretty frequent since the sync only runs when changes
        are detected.
    """
    last_tag = None

    if not config:
      logging.info("Using default config file")
      config = _get_default_config()

    logging.info("Config: %s", config)
    git_dir = os.path.dirname(config)

    client = secretmanager.SecretManagerServiceClient()

    secret_contents = load_secret(client, project, secret)
    creds_json = json.loads(secret_contents)
    creds = credentials.Credentials.from_authorized_user_info(creds_json)

    while True:
      # This is a bit of a hack. When relying on a side car (e.g. git-sync)
      # to synchronize the config the file may not be available when the
      # script first runs because the git sync hasn't completed yet.
      if not os.path.exists(config):
        logging.error("Config %s doesn't exist")
        time.sleep(period_seconds)
        continue

      latest = subprocess.check_output(["git", "describe", "--dirty",
                                        "--always"], cwd=git_dir)
      latest = latest.strip()

      logging.info("Current tag=%s; last run=%s", latest, last_tag)

      if latest != last_tag:
        logging.info("Running sync")
        sync_calendar(config, creds)
      else:
        logging.info("No changes; not syncing")

      last_tag = latest
      time.sleep(period_seconds)

  @staticmethod
  def mint_credentials(project, secret, oauth_client_secret):
    """Mint credentials for a particular user:

    The purpose of this command is to persist OAuth credentials for a
    desktop app to a file:
    https://developers.google.com/identity/protocols/oauth2/native-app

    The purpose of this is to allow impersonating a bot account for
    the purpose of automation.

    Args:
      project: GCP project to store the secret in
      secret: The id of a secret in GCP secret manager to save the secret
        to.
      oauth_client_secret: Path to the json file containing an OAuth client id
        for an OAuth application to use the Calendar API. Only required if
        not using a service account
    """

    # Create the Secret Manager client.
    client = secretmanager.SecretManagerServiceClient()

    create_secret(client, project, secret)

    # Build the resource name of the parent secret.
    parent = client.secret_path(project, secret)

    # Go through the webflow
    web_flow = flow.InstalledAppFlow.from_client_secrets_file(oauth_client_secret,
                                                                SCOPES)
    creds = web_flow.run_local_server(port=0)

    # Convert the string payload into a bytes. This step can be omitted if you
    # pass in bytes instead of a str for the payload argument.
    payload = creds.to_json().encode("UTF-8")

    # Add the secret version.
    response = client.add_secret_version(
        request={"parent": parent, "payload": {"data": payload}}
      )

    # Print the new secret version name.
    logging.info("Added secret version: {}".format(response.name))

if __name__ == "__main__":
  logging.basicConfig(level=logging.INFO,
                      format=('%(levelname)s|%(asctime)s'
                                '|%(pathname)s|%(lineno)d| %(message)s'),
                        datefmt='%Y-%m-%dT%H:%M:%S',
                      )
  logging.getLogger().setLevel(logging.INFO)
  fire.Fire(CalendarUpdater)

