# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

The first release, as 1.0.0.

### Added
- `GftUk::Cinema.all` and `GftUk::Cinema.new(id)` for Glasgow Film Theatre, keyed by its Indy Systems site id, `103`, with its address and coordinates from OpenStreetMap.
- `GftUk::Performance.at(id, from:, to:)`, from the consumer GraphQL API of the website, built on Indy Systems: one request for the advertised dates, then one for every ten dates. Sold out screenings are included without a booking link. Passes, workshops and live events are dropped.
- Variants and festivals from showing badges and titles, film years from titles or release dates, and title clean-up for festival and strand prefixes, anniversaries, prints and add-ons.
- Fixtures trimmed from live responses, a live shape test that checks real responses without storing them, and GitHub Actions CI and release workflows.
