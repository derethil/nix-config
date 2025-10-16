# Calendars Module

Synchronizes Outlook calendars via DavMail and vdirsyncer, with khal for CLI access.

## Initial Setup

After enabling the module and running `home-manager switch`, you must run discovery and sync once:

```bash
# 1. Discover calendars
vdirsyncer discover calendar_outlook

# Answer 'y' to create local collections

# 2. Run initial sync
vdirsyncer sync
```

**If you encounter duplicate UID errors:**

Outlook calendars sometimes have duplicate event UIDs. If sync fails with "multiple items with the same UID", run:

```bash
vdirsyncer repair calendar_outlook_remote/calendar
vdirsyncer sync
```

After the initial sync completes, vdirsyncer will automatically sync every 5 minutes via systemd timer.

## DavMail OAuth

The first time vdirsyncer connects to DavMail, DavMail will initiate OAuth authentication:
- Check DavMail logs: `journalctl --user -u davmail -f`
- Look for OAuth URL in the logs
- Open the URL in your browser and sign in with Outlook credentials
- DavMail saves the token to `~/.davmail.properties`

## Usage

After setup, use khal to view/manage calendars:

```bash
khal          # Interactive calendar
khal list     # List upcoming events
khal new      # Create new event
```

Calendar data is stored in `~/.config/calendars/outlook/`
