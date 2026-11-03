# frozen_string_literal: true

module GftUk
  # @api private
  module Internal
    module Parser
      # Parses a single Indy showing into performance attributes
      class Showing
        BOOKING_PATH = '/checkout/showing/'

        # Showing badges and the variants they mean. 'Subtitled' marks
        # foreign language films. Others, such as 'Accessible', '4K Screening',
        # 'Introduction', 'Preview' and 'BSL Interpretation', are not variants.
        BADGES = {
          '35mm Screening' => %w(35mm),
          '70mm Screening' => %w(70mm),
          'Access Take 2' => %w(kids relaxed),
          'As Live' => %w(arts),
          'Audio Described' => %w(audio_described),
          'Autism Friendly' => %w(relaxed),
          'Captioned' => %w(subtitled),
          'Deaf-friendly' => %w(subtitled),
          'Dementia Friendly' => %w(relaxed),
          'Event Cinema' => %w(arts),
          'Event Cinema - Encore' => %w(arts),
          'Q&A' => %w(q&a),
          'Recorded Q&A' => %w(q&a),
          'Subtitled' => %w(subtitled),
          'Take 2' => %w(kids)
        }.freeze

        # Retired badges stay on old showings with this suffix, e.g.
        # 'Take 2 - don't use'
        RETIRED = /\s*-\s*don['’]t use\z/i

        # Event cinema title classes, e.g. 'Event Cinema - Encore'
        EVENT_CINEMA = /\AEvent Cinema\b/

        # Badges naming a festival, with its edition when given
        FESTIVALS = {
          /\AFrench Film Festival\z/ => 'French Film Festival',
          /\AGlasgow Film Festival\z/ => 'Glasgow Film Festival',
          /\AGYFF\z/ => 'Glasgow Youth Film Festival',
          /\ASLA (20\d{2})\z/ => 'Scotland Loves Anime',
          /\ASMHAF\z/ => 'Scottish Mental Health Arts Festival'
        }.freeze

        # Title prefixes naming a festival
        TITLE_FESTIVALS = {
          /\AFFF: / => 'French Film Festival'
        }.freeze

        TITLE_VARIANTS = {
          /\b35mm\b/i => '35mm',
          /\b70mm\b/i => '70mm',
          /\bQ&A\b/i => 'q&a'
        }.freeze

        # Title classes for live events, talks and classes, e.g. 'GFT Live
        # Event', 'GFF Events', 'Workshops' and 'Education'
        NON_FILM_CLASSES = /\b(?:Live|Guest|Television) Event\b|\bEvents\b|\bWorkshops?\b|\bEducation\b/i
        NON_FILM_BADGES = %w(Workshop).freeze
        # Festival passes are sold as showings, e.g. 'Scotland Loves Anime
        # 2026 Weekend Pass'
        NON_FILM_TITLES = /\b(?:Pass|Gift Card|Voucher|Membership)\z/i

        THREE_D = /\b3D\b/i

        # @param [Hash] showing one showing, with its movie
        # @param [String] url the website's home page
        def initialize(showing, url:)
          @showing = showing
          @url = url
        end

        # Films only, on public sale
        # @return [Boolean]
        def film?
          public? && !title.match?(NON_FILM_TITLES) && !title_class.match?(NON_FILM_CLASSES) &&
            !badges.intersect?(NON_FILM_BADGES)
        end

        # @return [Hash] options for GftUk::Performance.new
        def to_hash
          {
            booking_url: booking_url,
            dimension: title.match?(THREE_D) ? '3d' : '2d',
            festival: festival,
            film_name: TitleSanitizer.new(title).sanitized,
            film_year: Cinebase::TitleSanitizer.film_year(title) || release_year,
            starting_at: starting_at,
            title: title,
            variant: variant
          }
        end

        private

        def badges
          @badges ||= @showing.fetch('showingBadges', []).map { |badge| badge.fetch('displayName').strip.sub(RETIRED, '') }
        end

        # Sold out showings have no seats remaining
        def booking_url
          if @showing['seatsRemaining'].to_i.positive?
            "#{@url}#{BOOKING_PATH}#{movie['urlSlug'] || movie['id']}/#{@showing.fetch('id')}/"
          end
        end

        def festival
          title_festival || Cinebase::Festival.from_title(title, year: london_year) || badge_festival
        end

        def badge_festival
          badges.each do |badge|
            FESTIVALS.each do |pattern, name|
              match = badge.match(pattern)
              return Cinebase::Festival.new(name: name, year: Integer(match[1] || london_year)) if match
            end
          end
          nil
        end

        def title_festival
          name = TITLE_FESTIVALS.find { |pattern, _| title.match?(pattern) }&.last
          Cinebase::Festival.new(name: name, year: london_year) if name
        end

        def london_year
          Cinebase::London.date(starting_at).year
        end

        def movie
          @showing.fetch('movie')
        end

        def public?
          @showing['published'] != false && @showing['private'] != true
        end

        def release_year
          movie['releaseDate']&.slice(0, 4)&.to_i
        end

        # Times are UTC, e.g. '2026-11-01T12:00:00Z'
        def starting_at
          @starting_at ||= Time.iso8601(@showing.fetch('time')).utc
        end

        def title
          @title ||= movie.fetch('name').strip
        end

        def title_class
          movie.dig('titleClass', 'name').to_s
        end

        def variant
          variants = badges.flat_map { |badge| BADGES.fetch(badge, []) }
          variants << 'arts' if title_class.match?(EVENT_CINEMA)
          variants += TITLE_VARIANTS.filter_map { |pattern, name| name if title.match?(pattern) }
          variants.uniq
        end
      end
    end
  end
end
