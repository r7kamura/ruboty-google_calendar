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

### How to issue an access token?
1. Open authorization page
1. Authorize
1. Get code parameter from redirect URL
1. Send POST request with the code

```sh
open "https://accounts.google.com/o/oauth2/auth\
?client_id=${GOOGLE_CLIENT_ID}\
&redirect_uri=http://localhost\
&scope=https://www.googleapis.com/auth/calendar\
&response_type=code\
&approval_prompt=force\
&access_type=offline"
```

```sh
curl \
  -d "client_id=${GOOGLE_CLIENT_ID}"\
  -d "client_secret=${GOOGLE_CLIENT_SECRET}"\
  -d "redirect_uri=http://localhost"\
  -d "grant_type=authorization_code"
  -d "code=${CODE}"\
   "https://accounts.google.com/o/oauth2/token"
```
