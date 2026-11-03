# GftUk

A simple gem to pull the cinema and its performances from the [Glasgow Film Theatre website](https://www.glasgowfilm.org) and spit out useful formatted info.

## Installation

Add this line to your application's Gemfile:

    gem 'gft_uk'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gft_uk

## Usage

The gem conforms to the API set down in the `cinebase` gem, [andycroll/cinebase](https://github.com/andycroll/cinebase), which provides a lot of useful base vocabulary and repetitive code for this series of cinema focussed gems.

No token or setup is needed. The website is a single page app on Indy
Systems, the Indy Cinema Group's platform. It reads its listings from a
GraphQL API at `/graphql`, which answers consumer queries that send the
headers `Client-Type: consumer` and `Site-Id: 103`. The gem asks the same
API.

### Cinema

Glasgow Film Theatre has one venue, keyed by its Indy site id, `103`. The
website gives no address or coordinates, so the gem holds them, from
OpenStreetMap. Cinema methods make no requests.

``` ruby
GftUk::Cinema.all
#=> [<GftUk::Cinema ...>]

cinema = GftUk::Cinema.new('103')
#=> <GftUk::Cinema ...>

cinema.adr
#=> {
  street_address:   '12 Rose Street',
  extended_address: nil,
  locality:         'Glasgow',
  region:           nil,
  postal_code:      'G3 6RB',
  country_name:     'United Kingdom'
}

cinema.brand
#=> 'Independent'

cinema.name
#=> 'Glasgow Film Theatre'

cinema.id
#=> '103'

cinema.latitude
#=> 55.8657225

cinema.url
#=> 'https://www.glasgowfilm.org'
```

### Performances

`Performance.at` returns performances for an inclusive range of showing dates,
defaulting to today in London and the following 13 days. The API lists the
dates with showings in one request. The gem then asks for ten of those dates
at a time, as aliased `showingsForDate` queries in one request. A year ahead
is about six requests.

``` ruby
GftUk::Performance.at('103', from: Date.today, to: Date.today + 365)
#=> [<GftUk::Performance ...>, <GftUk::Performance ...>, ...]

performance = GftUk::Performance.at('103', from: Date.today, to: Date.today + 365).first
#=> <GftUk::Performance ...>

performance.film_name
#=> 'The Money Maker' # from 'FFF: The Money Maker + Q&A'

performance.film_year
#=> 2026

performance.dimension
#=> '2d'

performance.variant
#=> ['q&a', 'subtitled']

performance.subtitled?
#=> true

performance.festival
#=> #<data Cinebase::Festival name="French Film Festival", year=2026>

performance.starting_at
#=> 2026-11-21 17:00:00 UTC

performance.booking_url
#=> 'https://www.glasgowfilm.org/checkout/showing/fff-the-money-maker-qa/500092/'

performance.cinema_name
#=> 'Glasgow Film Theatre'

performance.cinema_id
#=> '103'
```

Booking links open the website's ticket step for the showing. Sold out
screenings, with no seats remaining, are listed with no booking link.

Only films are listed. Showings that are unpublished or private, festival
passes such as 'Scotland Loves Anime 2026 Weekend Pass', workshops, and title
classes for live events, talks, television and education are dropped. Event
cinema, such as National Theatre Live, is kept.

Variants come from each showing's badges and from titles: `audio_described`,
`subtitled` (subtitled, captioned and deaf friendly screenings), `relaxed`
(autism and dementia friendly), `kids` (the Take 2 children's strand), `q&a`,
`35mm`, `70mm` and `arts` (event cinema). 4K, introductions, previews and BSL
interpretation are not variants.

Festivals come from badges (French Film Festival, Glasgow Film Festival,
GYFF, SLA, SMHAF) and from the `FFF:` title prefix. Film years come from a
year in the title, or else the film's release date.

Titles are cleaned up:

- Festival and strand prefixes go: 'FFF:', 'Take 2:', 'Take 2 Access:',
  'Access Film Club:', 'Movie Memories:', 'Youth Screening:' and 'Preview:'.
- Anniversaries, restorations and prints go: 'Marie Antoinette - 20th
  Anniversary - 4K', 'Short Cuts - 35mm', 'A Silent Voice (10th Anniversary)'.
- Add-ons go: '+ Q&A', '+ discussion', '+ introduction'.
- Series prefixes such as 'NT Live:' go, and the performance's `event` names
  the series, here National Theatre Live.

## Tests

```sh
bundle exec rake                # unit tests against fixtures
LIVE=1 bundle exec rake live    # live glasgowfilm.org
```

The fixtures in `test/fixtures` are GraphQL responses: every advertised date,
and a few films on some of those dates. `test/support/api_shapes.rb`
describes the fields the gem reads. The unit suite checks the fixtures against
it and the live suite checks real responses, held only in memory. When the API
changes, update the shape first, then the fixtures.

## Releasing

Bump the version, merge, then run the **Release Gem** workflow in GitHub
Actions. It runs the tests, tags the version and publishes the gem through
RubyGems trusted publishing.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
