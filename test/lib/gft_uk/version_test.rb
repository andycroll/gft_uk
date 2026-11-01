require_relative '../../test_helper'

class GftUk::VersionTest < Minitest::Test
  def test_version_is_defined
    refute_nil GftUk::VERSION
  end
end
