# frozen_string_literal: true

require 'json'
require 'net/http'

module GftUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Posts queries to the consumer GraphQL API of a website built on Indy
    # Systems, the Indy Cinema Group's platform
    class Graphql
      RETRIES = 2
      TRANSIENT_ERRORS = [
        EOFError, Errno::ECONNRESET, Errno::ECONNREFUSED, Net::OpenTimeout, Net::ReadTimeout, OpenSSL::SSL::SSLError
      ].freeze

      # @param [String] url the website's GraphQL endpoint
      # @param [String] site_id the venue's Indy site id
      def initialize(url, site_id:)
        @uri = URI(url)
        @site_id = site_id
      end

      # @param [String] document a GraphQL query
      # @param [Hash] variables the query's variables
      # @return [Hash] the response's data
      def query(document, variables = {})
        body = JSON.parse(post(JSON.generate(query: document, variables: variables)))
        # Indy reports a failed query in one 'error' object, not an 'errors' list
        error = body['error'] || Array(body['errors']).first
        if error
          raise "Indy GraphQL error: #{error['message']}"
        else
          body.fetch('data')
        end
      end

      private

      # Indy refuses consumer queries that name no site
      def post(body)
        request = Net::HTTP::Post.new(@uri)
        request['Content-Type'] = 'application/json'
        request['Client-Type'] = 'consumer'
        request['Site-Id'] = @site_id
        request.body = body
        response = with_retries { connection.request(request) }
        # Omit response bodies from errors, and never follow redirects.
        raise "Indy HTTP error #{response.code}" unless response.is_a?(Net::HTTPSuccess)

        String.new(response.body, encoding: Encoding::UTF_8)
      end

      # Net::HTTP never retries a POST itself
      def with_retries
        attempts = 0
        begin
          yield
        rescue *TRANSIENT_ERRORS
          attempts += 1
          raise if attempts > RETRIES

          @connection = nil
          sleep(attempts)
          retry
        end
      end

      # One connection for all of an import's requests
      def connection
        @connection ||= Net::HTTP.start(@uri.host, @uri.port, use_ssl: true, open_timeout: 10, read_timeout: 60)
      end
    end
  end
end
