require_relative '../../test_helper'

class GftUk::PerformanceTest < Minitest::Test
  include GraphqlStubs

  FIXTURE_DAY = Date.new(2026, 11, 1)
  YEAR_AHEAD = FIXTURE_DAY + 365

  def setup
    stub_graphql
  end

  def test_at_returns_films_in_time_order
    performances = GftUk::Performance.at('103', from: FIXTURE_DAY, to: YEAR_AHEAD)

    assert(performances.all? { |p| p.instance_of?(GftUk::Performance) })
    assert_equal 15, performances.count
    assert_equal performances.map(&:starting_at).sort, performances.map(&:starting_at)
  end

  def test_at_reads_every_advertised_date
    performances = GftUk::Performance.at(103, from: FIXTURE_DAY, to: YEAR_AHEAD)

    assert_equal Date.new(2027, 2, 18), performances.last.showing_on
    assert_requested :post, GRAPHQL, times: 1 + 5
  end

  def test_at_asks_only_for_dates_in_the_range
    performances = GftUk::Performance.at('103', from: Date.new(2026, 11, 14), to: Date.new(2026, 11, 14))

    assert_equal ['The LEGO Movie', 'Marie Antoinette'].sort, performances.map(&:film_name).sort
    assert_requested :post, GRAPHQL, times: 2
  end

  def test_at_defaults_to_two_weeks_from_today
    performances = GftUk::Performance.stub(:today, FIXTURE_DAY) { GftUk::Performance.at('103') }

    assert_equal 7, performances.count
    assert_operator performances.last.showing_on, :<=, FIXTURE_DAY + 13
  end

  def test_at_drops_passes
    films = GftUk::Performance.at('103', from: FIXTURE_DAY, to: YEAR_AHEAD).map(&:film_name)

    refute(films.any? { |film| film.include?('Pass') })
  end

  def test_at_sets_cinema_details
    performances = GftUk::Performance.at('103', from: FIXTURE_DAY, to: YEAR_AHEAD)

    assert_equal ['103'], performances.map(&:cinema_id).uniq
    assert_equal ['Glasgow Film Theatre'], performances.map(&:cinema_name).uniq
  end

  def test_at_unknown_cinema_makes_no_requests
    assert_empty GftUk::Performance.at('999', from: FIXTURE_DAY, to: YEAR_AHEAD)
    assert_not_requested :post, GRAPHQL
  end

  def test_at_rejects_a_reversed_range
    assert_raises(ArgumentError) { GftUk::Performance.at('103', from: FIXTURE_DAY, to: FIXTURE_DAY - 1) }
  end

  def test_today_is_the_london_date
    assert_kind_of Date, GftUk::Performance.send(:today)
  end
end
