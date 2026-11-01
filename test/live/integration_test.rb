require_relative 'live_helper'

# The advertised dates, then one request for every ten of them.
class LiveIntegrationTest < Minitest::Test
  include LiveHelper

  def test_the_cinema_has_performances_weeks_ahead
    today = Date.today
    performances = GftUk::Performance.at('103', from: today, to: today + 365)

    assert(performances.all? { |p| p.instance_of?(GftUk::Performance) })
    assert_operator performances.count, :>, 100
    assert_operator performances.map(&:showing_on).max, :>, today + 28
    assert(performances.filter_map(&:booking_url).all? { |url| url.match?(ApiShapes::BOOKING_URL) })
  end
end
