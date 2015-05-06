require "active_support/core_ext/date/calculations"
require "active_support/core_ext/numeric/time"
require "active_support/core_ext/object/try"
require "google/api_client"
require "google/api_client/client_secrets"
require "ruboty"
require "time"

module Ruboty
  module Handlers
    class GoogleCalendar < Base
      DEFAULT_CALENDAR_ID = "primary"
      DEFAULT_DURATION = 1.day

      env :GOOGLE_CALENDAR_ID, "Google Calendar ID (default: primary)", optional: true
      env :GOOGLE_CLIENT_ID, "Client ID"
      env :GOOGLE_CLIENT_SECRET, "Client Secret"
      env :GOOGLE_REDIRECT_URI, "Redirect URI (http://localhost in most cases)"
      env :GOOGLE_REFRESH_TOKEN, "Refresh token issued with access token"

      on(
        /list events( in (?<minute>\d+) minutes)?\z/,
        description: "List events from Google Calendar",
        name: "list_events",
      )

      def list_events(message)
        event_items = client.list_events(
          calendar_id: calendar_id,
          duration: message[:minute].try(:to_i).try(:minute) || DEFAULT_DURATION,
        ).items
        if event_items.size > 0
          text = event_items.map do |item|
            ItemView.new(item)
          end.join("\n")
          message.reply(text, code: true)
        else
          true
        end
      end

      private

      def calendar_id
        ENV["GOOGLE_CALENDAR_ID"] || DEFAULT_CALENDAR_ID
      end

      def client
        @client ||= Client.new(
          client_id: ENV["GOOGLE_CLIENT_ID"],
          client_secret: ENV["GOOGLE_CLIENT_SECRET"],
          redirect_uri: ENV["GOOGLE_REDIRECT_URI"],
          refresh_token: ENV["GOOGLE_REFRESH_TOKEN"],
        )
      end

      class Client
        APPLICATION_NAME = "ruboty-google_calendar"
        AUTH_URI = "https://accounts.google.com/o/oauth2/auth"
        SCOPE = "https://www.googleapis.com/auth/calendar"
        TOKEN_URI = "https://accounts.google.com/o/oauth2/token"

        def initialize(client_id: nil, client_secret: nil, redirect_uri: nil, refresh_token: nil)
          @client_id = client_id
          @client_secret = client_secret
          @redirect_uri = redirect_uri
          @refresh_token = refresh_token
          authenticate!
        end

        # @param [String] calendar_id
        # @param [ActiveSupport::Duration] duration
        def list_events(calendar_id: nil, duration: nil)
          api_client.execute(
            api_method: calendar.events.list,
            parameters: {
              calendarId: calendar_id,
              singleEvents: true,
              orderBy: "startTime",
              timeMin: Time.now.iso8601,
              timeMax: duration.since.iso8601
            }
          ).data
        end

        private

        def api_client
          @api_client ||= begin
            _api_client = Google::APIClient.new(
              application_name: APPLICATION_NAME,
              application_version: Ruboty::GoogleCalendar::VERSION,
            )
            _api_client.authorization = authorization
            _api_client.authorization.scope = SCOPE
            _api_client
          end
        end

        def authenticate!
          api_client.authorization.fetch_access_token!
        end

        def authorization
          client_secrets.to_authorization
        end

        def client_secrets
          Google::APIClient::ClientSecrets.new(
            flow: :installed,
            installed: {
              auth_uri: AUTH_URI,
              client_id: @client_id,
              client_secret: @client_secret,
              redirect_uris: [@redirect_uri],
              refresh_token: @refresh_token,
              token_uri: TOKEN_URI,
            },
          )
        end

        def calendar
          @calendar ||= api_client.discovered_api("calendar", "v3")
        end
      end

      class ItemView
        def initialize(item)
          @item = item
        end

        def to_s
          "#{started_at} - #{finished_at} #{summary}"
        end

        private

        def all_day?
          @item.start.date_time.nil?
        end

        def finished_at
          case
          when all_day?
            "--:--"
          when finished_in_same_day?
            @item.end.date_time.localtime.strftime("%H:%M")
          else
            @item.end.date_time.localtime.strftime("%Y-%m-%d %H:%M")
          end
        end

        def finished_in_same_day?
          @item.start.date_time.localtime.day == @item.end.date_time.localtime.day
        end

        def started_at
          if all_day?
            "#{@item.start.date} --:--"
          else
            @item.start.date_time.localtime.strftime("%Y-%m-%d %H:%M")
          end
        end

        def summary
          @item.summary
        end
      end
    end
  end
end
