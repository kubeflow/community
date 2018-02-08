# Hosting Kubeflow Community Meetings

Author(s): Edd Wilder-James [@ewilderj](http://github.com/ewilderj)

## Prerequisites

* A paid [Zoom](http://zoom.us/) account. At the time of writing, a "Pro" level account should be sufficient.

## Setting up the meeting

For a meeting that already exists, get yourself added as a host from the Zoom
interface. Contact the relevant meeting organizer:

* Main community meeting: [@ewilderj](mailto:ewj@google.com) 

No less than 24 hours before the meeting, circulate the agenda and notes Google
doc:

1. Create a Google doc, make it public viewable, and editable by
   *kubeflow-discuss@googlegroups.com*, this will allow the community members to
   help you crowdsource notes. Please note that you cannot make a Google Doc
   public viewable from some corporate accounts, e.g. google.com, so using a
   personal Gmail account might be necessary.
   
2. Bring the agenda items in (usually queued from the week's previous calls, or
   suggested for discussion on the mailing list) at the top
   
3. Circulate the agenda document to the mailing list, along with a reminder of
   the Zoom call in details. You can get these from the Zoom interface.

## Creating a new meeting in Zoom

A few guidelines:

* Be sensitive to the timezone of your participants. If there's no one good
  time, rotate your meeting through two options (e.g. 8am PT & 4pm PT)

* Configure the meeting to be recorded, so you can share audio afterwards

* To keep the same meeting ID every time, mark the meeting as recurring. If your
  meeting doesn't have a regular time, you can still keep the same meeting ID by
  not specifying a schedule.
  
* Ensure your meeting is configured with both phone dial-in and audio
  conferencing capability.

* Send a calendar invite to the participating group (usually a mailing list). In
  the invitation, include both the Zoom URL and dial-in details for the most
  common regions in your meeting. This info is available to cut and paste from
  the Zoom interface. Here's an example description:

```
Join from PC, Mac, Linux, iOS or Android: https://zoom.us/j/799749911

Or iPhone one-tap:
US: +16699006833,,799749911# or +16465588656,,799749911# 
Or Telephone:
Dial (for higher quality, dial a number based on your current location): 
US: +1 669 900 6833 or +1 646 558 8656 
France: +33 (0) 1 8288 0188 
Germany: +49 (0) 30 3080 6188 
Ireland: +353 (0) 1 691 7488 
United Kingdom: +44 (0) 20 3695 0088 
South Korea: +82 (0) 2 6022 2322 
Japan: +81 (0) 3 4578 1488 
Malaysia: +60 3 9212 1727 
Singapore: +65 3158 7288 
Australia: +61 (0) 2 8015 2088 
New Zealand: +64 (0) 9 801 1188 or +64 (0) 4 831 8959 
Hong Kong: +852 5808 6088 
Meeting ID: 799 749 911
International numbers available: https://zoom.us/zoomconference?m=Os1EjlUlpb2_XUMaQ6dX1azqMK5CkfWH
```




## Running the meeting

Start the Zoom meeting 5 minutes before its assigned time.  The meeting should
be configured that new arrivals are muted by default, to save noise.  Usually,
you'll need to tell people at the start time that you'll wait a couple of
minutes to allow everybody 
to arrive.

Post a link to the agenda & notes into the relevant Slack channel: for the main
community meeting, this is *#community*.

Kick off by welcoming people, reminding them of the Slack channel for feedback,
and the link for agenda/notes. Hand off to the team member driving the agenda,
if it is not you.

Remind people of some good practices:

* The meeting is public and will be recorded, let people know this.

* It's hard to know who's talking, so attendees should introduce themselves
  before making a comment.
  
* If you can't get into the conversation and want to contribute, post to the
  Slack channel and tag the meeting moderator to get attention.

* Folks should add relevant links and info into the meeting doc, rather than the
  Zoom channel, as the Zoom chat will go away at the end of the meeting.
  
## Taking notes

If you are not going to be the note-taker, ensure there is a designated
volunteer to take notes before discussion starts.

Ensure that action items that people have agreed to are clearly noted.

## After the meeting

* Edit the notes for clarity, applying formatting to separate discussion items.

* Ensure that action items are tagged to the community members responsible: the
  easiest way to do this is highlight and add a comment tagging their email
  address with a `+` sign.
  
* When Zoom emails you to say the audio recording is available, get the share
  link for the audio recording and insert it at the top of the doc. (If there is
  a video recording, I usually delete this as it's not a lot of use and takes up
  space.)
  
* Circulate the notes link to the mailing list. 

* Leave the doc editable for a few hours for incoming amendments, then change
  the sharing so the group has *Comment & Suggest* permissions. This is to avoid
  us having worry about after-the-fact changes that the community doesn't get
  notified of.
  
## That's it!

If you have suggestions or improvements, please submit a PR to this
documentation or discuss it on the group mailing list.


  



