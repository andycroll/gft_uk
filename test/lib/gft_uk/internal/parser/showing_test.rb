require_relative '../../../../test_helper'

class GftUk::Internal::Parser::ShowingTest < Minitest::Test
  include FixturesHelper

  URL = 'https://www.glasgowfilm.org'.freeze

  def test_to_hash_reads_a_showing
    expected = {
      booking_url: "#{URL}/checkout/showing/all-day-horror-madness/488172/",
      dimension: '2d',
      festival: nil,
      film_name: 'All Day Horror Madness',
      film_year: 2023,
      starting_at: Time.utc(2026, 11, 1, 12, 0),
      variant: %w(35mm)
    }

    assert_equal expected, parse(fixture('All Day Horror Madness')).to_hash
  end

  def test_sold_out_showings_have_no_booking_url
    assert_nil parse(fixture('Fatherland')).to_hash[:booking_url]
  end

  def test_booking_url_falls_back_to_the_movie_id
    showing = fixture('Gentle Monster')
    showing['movie']['urlSlug'] = nil

    assert_equal "#{URL}/checkout/showing/40630/#{showing['id']}/", parse(showing).to_hash[:booking_url]
  end

  def test_films_on_public_sale
    assert_predicate parse(fixture('Gentle Monster')), :film?
  end

  def test_unpublished_and_private_showings_are_not_films
    refute_predicate parse(fixture('Gentle Monster').merge('published' => false)), :film?
    refute_predicate parse(fixture('Gentle Monster').merge('private' => true)), :film?
  end

  def test_passes_are_not_films
    refute_predicate parse(fixture('Scotland Loves Anime 2026 Weekend Pass')), :film?
  end

  def test_live_events_and_workshops_are_not_films
    event = fixture('Gentle Monster')
    event['movie']['titleClass'] = { 'name' => 'GFT Live Event' }
    workshop = fixture('Gentle Monster').merge('showingBadges' => [{ 'displayName' => 'Workshop' }])

    refute_predicate parse(event), :film?
    refute_predicate parse(workshop), :film?
  end

  def test_event_cinema_is_a_film
    assert_predicate parse(fixture('NT Live: The Motive and the Cue')), :film?
  end

  def test_badge_variants
    assert_equal %w(kids), variant('Take 2: Flight of the Navigator')
    assert_equal %w(relaxed kids subtitled).sort, variant('Take 2 Access: The LEGO Movie').sort
    assert_equal %w(relaxed), variant('Movie Memories: An Affair to Remember')
  end

  def test_retired_badges_still_count
    assert_includes variant("Take 2: Nina and the Hedgehog's Secret"), 'kids'
  end

  def test_event_cinema_is_arts
    assert_includes variant('NT Live: The Motive and the Cue'), 'arts'
    assert_equal %w(arts), variant('GIANT - The Play')
  end

  def test_title_variants
    assert_equal %w(35mm), variant('Short Cuts - 35mm')
    assert_includes variant("It's Nice Up North - 20th Anniversary + Q&A"), 'q&a'
  end

  def test_badge_festivals_with_and_without_an_edition
    showing = fixture('The Obsessed')

    assert_equal Cinebase::Festival.new(name: 'Scotland Loves Anime', year: 2026), parse(showing).to_hash[:festival]

    showing['showingBadges'] = [{ 'displayName' => 'SMHAF' }]
    festival = Cinebase::Festival.new(name: 'Scottish Mental Health Arts Festival', year: 2026)

    assert_equal festival, parse(showing).to_hash[:festival]
  end

  def test_title_festivals
    festival = Cinebase::Festival.new(name: 'French Film Festival', year: 2026)

    assert_equal festival, parse(fixture('FFF: The Money Maker + Q&A')).to_hash[:festival]
  end

  def test_cinebase_festival_prefixes
    showing = fixture('Gentle Monster')
    showing['movie']['name'] = 'Horror Season 2026 Gentle Monster'

    assert_equal Cinebase::Festival.new(name: 'Horror Season', year: 2026), parse(showing).to_hash[:festival]
  end

  def test_years_in_titles_come_before_release_dates
    showing = fixture('Gentle Monster')
    showing['movie']['name'] = 'Gentle Monster (1999)'

    assert_equal 1999, parse(showing).to_hash[:film_year]
  end

  def test_missing_release_dates_give_no_year
    assert_nil parse(fixture('NT Live: The Motive and the Cue')).to_hash[:film_year]
  end

  def test_three_d_titles
    showing = fixture('Gentle Monster')
    showing['movie']['name'] = 'Gentle Monster 3D'

    assert_equal '3d', parse(showing).to_hash[:dimension]
  end

  private

  def fixture(name)
    showings_by_date.values.flat_map { |result| result['data'] }.detect { |showing| showing.dig('movie', 'name') == name }
  end

  def parse(showing)
    GftUk::Internal::Parser::Showing.new(showing, url: URL)
  end

  def variant(name)
    parse(fixture(name)).to_hash[:variant]
  end
end
