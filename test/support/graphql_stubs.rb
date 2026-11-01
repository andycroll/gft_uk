require_relative 'fixtures_helper'

# Answer GraphQL queries from the fixtures in place of the website
module GraphqlStubs
  include FixturesHelper

  GRAPHQL = 'https://www.glasgowfilm.org/graphql'.freeze

  private

  def stub_graphql
    stub_request(:post, GRAPHQL).to_return do |request|
      body = JSON.parse(request.body)
      { status: 200, body: body['query'].include?('datesWithShowing') ? dates_json : showings_json(body['variables']) }
    end
  end

  # Each date variable, e.g. 'd0' => '2026-11-01', names an alias in the query
  def showings_json(variables)
    by_date = showings_by_date
    dates = variables.except('siteIds')
    JSON.generate(data: dates.transform_values { |date| by_date.fetch(date, { 'data' => [] }) })
  end
end
