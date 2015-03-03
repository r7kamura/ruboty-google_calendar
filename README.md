# Ruboty::GoogleCalendar
[Ruboty](https://github.com/r7kamura/ruboty) plug-in to read schedule from Google Calendar.

## Usage
```
> @ruboty list events
2015-03-04 09:30 - 09:40 Stand-up meeting
2015-03-04 14:00 - 15:00 Engineering meeting
```

## ENV
Note: You need to register a native application client on
[Google Developers Console](https://console.developers.google.com),
then issue an access token (with a refresh token) by yourself.

```
GOOGLE_CALENDAR_ID   - Google Calendar ID (default: primary)
GOOGLE_CLIENT_ID     - Client ID
GOOGLE_CLIENT_SECRET - Client Secret
GOOGLE_REDIRECT_URI  - Redirect URI (http://localhost in most cases)
GOOGLE_REFRESH_TOKEN - Refresh token issued with access token
```
