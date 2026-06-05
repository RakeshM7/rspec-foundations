# frozen_string_literal: true

# lib/api/base_client.rb
# ─────────────────────────────────────────────────────────────────────────────
# HTTParty base class. All entity clients inherit from this.
#
# WHY a base class vs including HTTParty in each client?
# Single place to configure auth, base URI, headers, and error handling.
# Entity clients only define methods specific to their resource.
#
# INTERVIEW: explain the auth mechanism.
# Freshservice V2 uses HTTP Basic auth where the API key is the username
# and the password can be any string (e.g. "X"). The key is never embedded
# in code — it's read from ENV at runtime.
# ─────────────────────────────────────────────────────────────────────────────

require 'httparty'
require 'json'

module API
  class BaseClient
    include HTTParty

    # Base URI is set once here. Entity clients override :path only.
    base_uri "#{ENV.fetch('APP_URL', 'https://yourdomain.freshservice.com')}/api/v2"

    print "base_uri :: #{base_uri}"

    headers(
      'Content-Type' => 'application/json',
      'Accept'       => 'application/json'
    )

    # Basic auth: API key as username, literal "X" as password.
    basic_auth ENV.fetch('FS_API_KEY', ''), 'X'

    # Timeout settings — critical for CI where network can be slow.
    default_timeout 30

    class << self
      # Wraps HTTParty responses with consistent error surfacing.
      # In tests you assert on .code and .parsed_response directly.
      def get_resource(path, query: {})
        response = get(path, query: query)
        log_response(:GET, path, response)
        response
      end

      def post_resource(path, body:)
        response = post(path, body: body.to_json)
        log_response(:POST, path, response)
        response
      end

      def put_resource(path, body:)
        response = put(path, body: body.to_json)
        log_response(:PUT, path, response)
        response
      end

      def delete_resource(path)
        response = delete(path)
        log_response(:DELETE, path, response)
        response
      end

      private

      def log_response(method, path, response)
        # Store on the example group so after(:each, :api) hook can attach it to Allure
        Thread.current[:last_api_response] = response
        return unless ENV['API_DEBUG'] == 'true'

        puts "\n#{method} #{base_uri}#{path} → #{response.code}"
        puts JSON.pretty_generate(response.parsed_response) rescue nil
      end
    end
  end
end
