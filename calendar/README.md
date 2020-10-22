# Kubeflow community calendar

This is location for [Kubeflow community calendar](https://calendar.google.com/calendar/embed?src=kubeflow.org_7l5vnbn8suj2se10sen81d9428@group.calendar.google.com).
You can find list for all meetings in [`calendar.yaml`](calendar.yaml) file.

## Add new meeting to the calendar

To add new meeting to the Kubeflow calendar follow these steps:

1. Add new record to [`calendar.yaml`](calendar.yaml) with meeting parameters.
   Information about each field you can find in the file.

1. After updating the file, you have to ask anyone from [OWNERS](OWNERS) file
   to manually run [`calendar_import.py`](../scripts/calendar_import.py) to update
   Kubeflow calendar.

1. Then you should be able to see your new meeting in the calendar.

## Automating calendar_import.py

`calendar_import.py` is designed to run automatically using a robot account. 

* We deploy it on Kubernetes
* We run [git-sync](https://github.com/kubernetes/git-sync) in a side car to synchronize the repo to a volume mount
* When calendar_import.py detects a change it runs the sync

### Where it Runs

* Project: kf-infra-gitops

* Project configs [kubeflow/community-infra/tree/master/prod/namespaces/kf-infra-gitops](https://github.com/kubeflow/community-infra/tree/master/prod/namespaces/kf-infra-gitops)


### Using a Google Service Account with the Calendar API

* We need to enable [Domain Delegation](https://developers.google.com/identity/protocols/oauth2/service-account)
  for the service account

  * Without this the GSA can add events to the calendar but not invite attendees to the meeting
  * Domain wide configuration is restricted to the calendar scope to minimize the damage this can do

* In order to use domain wide configuration the GSA needs to impersonate a user; we have created the account "autobot.kubeflow.org" for this

## Before running `calendar_import.py`

1. You need to be calendar admin in kubeflow.org.

1. You need to join the [kubeflow-discuss google group](https://groups.google.com/g/kubeflow-discuss), because

    > Tip: If you have "View members" access to a group and create a group event, each member receives an invitation email. If you do not have  “View members” access, the group receives an invitation. Each user must accept the invite for the event to display appear on their calendar.

    Note if you are using a user@kubeflow.org email account, you should join kubeflow-discuss with this account.

1. You need a Google Cloud project (not sure whether it must be in kubeflow.org).

1. Go to https://console.cloud.google.com/apis/credentials, create an OAuth 2.0 Client ID choosing `Desktop app` type.

1. Visit the newly created OAuth 2.0 Client ID and click "Download JSON" button on top.

1. Move the json file to `~/secrest/kf-calendar.oauth_client.json`.

1. `pip install -r scripts/requirements.txt`
