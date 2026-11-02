module GftUk
  # A single screening of a film on the Glasgow Film Theatre website
  class Performance < Cinebase::Performance
    # @!attribute [r] booking_url
    #   @return [String, nil] the booking URL, nil when sold out
    # @!attribute [r] cinema_name
    #   @return [String] the cinema name
    # @!attribute [r] cinema_id
    #   @return [String] the cinema id
    # @!attribute [r] dimension
    #   @return [String] 2d or 3d
    # @!attribute [r] film_name
    #   @return [String] the film name

    # @!method initialize(options)
    #   @param [Hash] options options hash
    #   @option options [String] :booking_url (nil) buying url for the screening
    #   @option options [String] :cinema_name name of the cinema
    #   @option options [String] :cinema_id website id of the cinema
    #   @option options [String] :dimension ('2d') dimension of the screening
    #   @option options [Cinebase::Festival] :festival (nil) festival edition
    #   @option options [String] :film_name name of the film
    #   @option options [Integer] :film_year (nil) year of the film
    #   @option options [Time] :starting_at listed start time of the performance

    # Performances within an inclusive range of showing dates: one request
    # for the dates with showings, then one for every ten of those dates.
    # @param [Integer, String] cinema_id the cinema's Indy site id, '103'
    # @param [Date] from first date (defaults to today in London)
    # @param [Date] to last date (defaults to 13 days after from)
    # @return [Array<GftUk::Performance>]
    def self.at(
      cinema_id,
      from: Cinebase::London.today,
      to: from + 13
    )
      raise ArgumentError, 'to must not precede from' if to < from

      cinema = Cinema.new(cinema_id)
      if cinema.name.empty?
        []
      else
        performances = showings(cinema, from..to).map do |showing|
          new(showing.to_hash.merge(cinema_id: cinema.id, cinema_name: cinema.name))
        end
        performances.sort_by(&:starting_at)
      end
    end

    # @!method showing_on
    #   The date of the screening
    #   @return [Date]

    # @!method starting_at
    #   UTC time of the screening
    #   @return [Time]

    # @!method variant
    #   The kinds of screening (arts, audio_described, kids, relaxed, subtitled ...)
    #   @return <Array[String]>

    def self.showings(cinema, dates)
      indy = GftUk::Internal::Indy.new(cinema.url, site_id: cinema.id)
      indy.showings(indy.dates.select { |date| dates.cover?(date) })
          .map { |showing| GftUk::Internal::Parser::Showing.new(showing, url: cinema.url) }
          .select(&:film?)
    end
    private_class_method :showings
  end
end
