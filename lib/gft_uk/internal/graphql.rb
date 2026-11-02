# frozen_string_literal: true

require 'json'

module GftUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Posts queries to the consumer GraphQL API of a website built on Indy
    # Systems, the Indy Cinema Group's platform
    class Graphql
      READ_TIMEOUT = 60

      # @param [String] url the website's GraphQL endpoint
      # @param [String] site_id the venue's Indy site id
      def initialize(url, site_id:)
        @url = url
        # Indy refuses consumer queries that name no site
        @headers = { 'Client-Type' => 'consumer', 'Site-Id' => site_id }
        # One connection for all of an import's requests
        @http = Cinebase::Http.new(read_timeout: READ_TIMEOUT, keep_alive: true)
      end

      # @param [String] document a GraphQL query
      # @param [Hash] variables the query's variables
      # @return [Hash] the response's data
      def query(document, variables = {})
        body = JSON.parse(@http.post(@url, json: { query: document, variables: variables }, headers: @headers))
        # Indy reports a failed query in one 'error' object, not an 'errors' list
        error = body['error'] || Array(body['errors']).first
        if error
          raise "Indy GraphQL error: #{error['message']}"
        else
          body.fetch('data')
        end
      end
    end
  end
end
