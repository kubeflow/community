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
