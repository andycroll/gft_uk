require_relative '../../../test_helper'

class GftUk::Internal::IndyTest < Minitest::Test
  include GraphqlStubs

  def setup
    stub_graphql
  end

  def test_dates_are_every_advertised_date
    dates = indy.dates

    assert_equal 46, dates.count
    assert_equal Date.new(2026, 11, 1), dates.first
    assert_equal Date.new(2027, 2, 18), dates.last
  end

  def test_showings_ask_for_ten_dates_a_request
    dates = indy.dates
    showings = indy.showings(dates)

    assert_equal 16, showings.count
    assert_equal 'All Day Horror Madness', showings.first.dig('movie', 'name')
    assert_equal 'NT Live: The Motive and the Cue', showings.last.dig('movie', 'name')
    assert_requested :post, GRAPHQL, times: 1 + 5
  end

  def test_showings_query_names_each_date
    indy.showings([Date.new(2026, 11, 1), Date.new(2026, 11, 6)])

    assert_requested(:post, GRAPHQL) do |request|
      body = JSON.parse(request.body)
      body['variables'] == { 'd0' => '2026-11-01', 'd1' => '2026-11-06', 'siteIds' => ['103'] } &&
        body['query'].include?('d1: showingsForDate(date: $d1, siteIds: $siteIds)')
    end
  end

  def test_no_dates_make_no_requests
    assert_empty indy.showings([])
    assert_not_requested :post, GRAPHQL
  end

  private

  def indy
    @indy ||= GftUk::Internal::Indy.new('https://www.glasgowfilm.org', site_id: '103')
  end
end
