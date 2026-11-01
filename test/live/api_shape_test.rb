require_relative 'live_helper'

class LiveApiShapeTest < Minitest::Test
  include ApiShapes
  include LiveHelper

  def test_dates_are_readable
    assert_dates_shape(indy.dates)
  end

  def test_showings_are_readable
    assert_showings_shape(indy.showings(indy.dates.first(2)))
  end

  private

  def indy
    @indy ||= GftUk::Internal::Indy.new('https://www.glasgowfilm.org', site_id: '103')
  end
end
