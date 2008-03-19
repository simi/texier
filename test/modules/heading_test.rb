require "#{File.dirname(__FILE__)}/../test_helper"
require 'processor'

# Test case for Texier::Modules::Basic class
class HeadingTest < Test::Unit::TestCase
  def test_single_surrounded_heading
    assert_output(
      '<h1>hello world</h1>',
      '####### hello world'
    )
  end
end
