# Read fixtures from disk: responses captured from the website's GraphQL API.
# The dates are every advertised date; the showings keep a few films on some
# of those dates. They follow the shape in api_shapes.rb.
module FixturesHelper
  private

  def dates_json
    read_fixture('graphql/dates.json')
  end

  # @return [Hash{String => Hash}] each date's showingsForDate result
  def showings_by_date
    JSON.parse(read_fixture('graphql/showings.json'))
  end

  def read_fixture(filepath)
    File.read(File.expand_path("../../fixtures/#{filepath}", __FILE__))
  end
end
