require 'date'
require 'json'
require 'time'

require 'cinebase'

require_relative './gft_uk/version'

require_relative './gft_uk/internal/graphql'
require_relative './gft_uk/internal/indy'
require_relative './gft_uk/internal/title_sanitizer'
require_relative './gft_uk/internal/parser/showing'

require_relative './gft_uk/cinema'
require_relative './gft_uk/performance'

# gft_uk gem
module GftUk
end
