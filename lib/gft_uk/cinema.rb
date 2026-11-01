module GftUk
  # The object representing Glasgow Film Theatre
  class Cinema < Cinebase::Cinema
    # @!attribute [r] id
    #   @return [String] the cinema's Indy Systems site id, '103'

    # The cinema has one venue, keyed by the site id its website's GraphQL
    # API takes. The website gives no address or coordinates, so the gem
    # holds them.
    VENUES = {
      '103' => {
        name: 'Glasgow Film Theatre', street_address: '12 Rose Street', locality: 'Glasgow',
        postal_code: 'G3 6RB', latitude: 55.8657225, longitude: -4.2612728
      }
    }.freeze

    ADDRESS_PARTS = %i(street_address extended_address locality region postal_code).freeze
    URL = 'https://www.glasgowfilm.org'.freeze

    # Constructor
    # @param [Integer, String] id the cinema's Indy site id, 103 or '103'
    # @return [GftUk::Cinema]
    def initialize(id)
      @id = id.to_s
    end

    # Return basic cinema information for all cinemas
    # @return [Array<GftUk::Cinema>] the one cinema
    # @example
    #   GftUk::Cinema.all
    #   #=> [<GftUk::Cinema>]
    def self.all
      VENUES.keys.map { |id| new(id) }
    end

    # @!method address
    #   Address of the cinema
    #   @return [Hash] of different address parts
    #   @see #adr

    # Address of the cinema
    # @return [Hash] contains :street_address, :extended_address,
    # :locality, :region, :postal_code, :country_name
    # @example
    #   cinema = GftUk::Cinema.new('103')
    #   cinema.adr
    #   #=> {
    #         street_address:   '12 Rose Street',
    #         extended_address: nil,
    #         locality:         'Glasgow',
    #         region:           nil,
    #         postal_code:      'G3 6RB',
    #         country_name:     'United Kingdom'
    #       }
    # @note Uses method naming as at http://microformats.org/wiki/adr
    def adr
      ADDRESS_PARTS.to_h { |part| [part, venue[part]] }.merge(country_name: 'United Kingdom')
    end

    # Brand of the cinema
    # @return [String] which will always be 'Independent'
    def brand
      'Independent'.freeze
    end

    # @return [Float, nil]
    def latitude
      venue[:latitude]
    end

    # @return [Float, nil]
    def longitude
      venue[:longitude]
    end

    # The name of the cinema
    # @return [String]
    # @example
    #   GftUk::Cinema.new('103').name
    #   #=> 'Glasgow Film Theatre'
    def name
      venue[:name].to_s
    end

    # The url of the cinema's website
    # @return [String]
    # @example
    #   GftUk::Cinema.new('103').url
    #   #=> 'https://www.glasgowfilm.org'
    def url
      venue.empty? ? '' : URL
    end

    private

    def venue
      VENUES.fetch(id, {})
    end
  end
end
