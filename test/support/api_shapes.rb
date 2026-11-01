# The parts of GraphQL responses the gem reads. Checked against the fixtures
# and, in the live suite, against real responses held only in memory.
module ApiShapes
  BOOKING_URL = %r{\Ahttps://www\.glasgowfilm\.org/checkout/showing/[\w-]+/\d+/\z}

  private

  def assert_dates_shape(dates)
    refute_empty dates
    assert(dates.all? { |date| date.instance_of?(Date) })
    assert_equal dates.sort, dates
  end

  def assert_showings_shape(showings)
    refute_empty showings
    showings.each do |showing|
      assert_match(/\A\d+\z/, showing.fetch('id'))
      assert_match(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z\z/, showing.fetch('time'))
      assert_includes [true, false], showing.fetch('published')
      assert_includes [true, false], showing.fetch('private')
      assert_kind_of Integer, showing.fetch('seatsRemaining')
      showing.fetch('showingBadges').each { |badge| assert_kind_of String, badge.fetch('displayName') }
      assert_movie_shape(showing.fetch('movie'))
    end
  end

  def assert_movie_shape(movie)
    assert_match(/\A\d+\z/, movie.fetch('id'))
    assert_kind_of String, movie.fetch('name')
    assert_match(/\A[\w-]+\z/, movie.fetch('urlSlug')) if movie['urlSlug']
    assert_match(/\A\d{4}-\d{2}-\d{2}\z/, movie.fetch('releaseDate')) if movie['releaseDate']
    assert_kind_of String, movie.fetch('titleClass').fetch('name')
  end
end
