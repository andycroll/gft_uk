# frozen_string_literal: true

module GftUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Reads a venue's listings from a website built on Indy Systems
    class Indy
      # Dates are aliased showingsForDate queries in one request. Ten keeps
      # each response to a couple of seconds.
      DATES_PER_REQUEST = 10

      DATES_QUERY = <<~GRAPHQL
        query ($siteIds: [ID]) { datesWithShowing(siteIds: $siteIds) { value } }
      GRAPHQL

      SHOWING_FIELDS = <<~GRAPHQL
        data {
          id time published private seatsRemaining
          showingBadges { displayName }
          movie { id name urlSlug releaseDate titleClass { name } }
        }
      GRAPHQL

      # @param [String] url the website's home page
      # @param [String] site_id the venue's Indy site id
      def initialize(url, site_id:)
        @graphql = Graphql.new("#{url}/graphql", site_id: site_id)
        @site_id = site_id
      end

      # @return [Array<Date>] every date with showings on sale
      def dates
        value = @graphql.query(DATES_QUERY, siteIds: [@site_id]).dig('datesWithShowing', 'value')
        JSON.parse(value).map { |date| Date.iso8601(date) }
      end

      # @param [Array<Date>] dates listings dates, in London
      # @return [Array<Hash>] the showings on those dates, each with its movie
      def showings(dates)
        dates.each_slice(DATES_PER_REQUEST).flat_map do |slice|
          variables = slice.each_with_index.to_h { |date, index| ["d#{index}", date.iso8601] }
          data = @graphql.query(showings_query(variables.keys), variables.merge('siteIds' => [@site_id]))
          variables.keys.flat_map { |key| data.dig(key, 'data') || [] }
        end
      end

      private

      def showings_query(keys)
        params = keys.map { |key| "$#{key}: String" }.join(', ')
        fields = keys.map { |key| "#{key}: showingsForDate(date: $#{key}, siteIds: $siteIds) { #{SHOWING_FIELDS} }" }
        "query (#{params}, $siteIds: [ID]) { #{fields.join(' ')} }"
      end
    end
  end
end
