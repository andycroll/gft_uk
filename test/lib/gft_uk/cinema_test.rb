require_relative '../../test_helper'

class GftUk::CinemaTest < Minitest::Test
  def test_all_returns_the_one_cinema_without_requests
    cinemas = GftUk::Cinema.all

    assert(cinemas.all? { |cinema| cinema.instance_of?(GftUk::Cinema) })
    assert_equal %w(103), cinemas.map(&:id)
  end

  def test_new_stores_string_id
    assert_equal '103', GftUk::Cinema.new(103).id
  end

  def test_name_full_name_and_slug
    cinema = GftUk::Cinema.new('103')

    assert_equal 'Glasgow Film Theatre', cinema.name
    assert_equal 'Independent Glasgow Film Theatre', cinema.full_name
    assert_equal 'independent-glasgow-film-theatre', cinema.slug
  end

  def test_brand
    assert_equal 'Independent', GftUk::Cinema.new('103').brand
  end

  def test_url
    assert_equal 'https://www.glasgowfilm.org', GftUk::Cinema.new('103').url
  end

  def test_adr
    expected = {
      street_address:   '12 Rose Street',
      extended_address: nil,
      locality:         'Glasgow',
      region:           nil,
      postal_code:      'G3 6RB',
      country_name:     'United Kingdom'
    }

    assert_equal expected, GftUk::Cinema.new('103').adr
  end

  def test_coordinates
    cinema = GftUk::Cinema.new('103')

    assert_in_delta 55.8657225, cinema.latitude
    assert_in_delta(-4.2612728, cinema.longitude)
  end

  def test_unknown_cinema_has_no_details
    cinema = GftUk::Cinema.new('999')

    assert_equal '', cinema.name
    assert_equal '', cinema.url
    assert_nil cinema.latitude
    assert_nil cinema.longitude
  end
end
