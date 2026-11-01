require_relative '../../../test_helper'

class FixtureShapeTest < Minitest::Test
  include ApiShapes
  include GraphqlStubs

  def setup
    stub_graphql
  end

  def test_dates_fixture_matches_shape
    assert_dates_shape(indy.dates)
  end

  def test_showings_fixture_matches_shape
    assert_showings_shape(indy.showings(indy.dates))
  end

  private

  def indy
    @indy ||= GftUk::Internal::Indy.new('https://www.glasgowfilm.org', site_id: '103')
  end
end
