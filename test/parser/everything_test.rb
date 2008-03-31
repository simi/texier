require "#{File.dirname(__FILE__)}/../test_helper"

class EverythingTest < Test::Unit::TestCase
  def test_everything
    parser = everything
    
    assert_nil parser.parse('')
    assert_equal ['foo'], parser.parse('foo')
  end
end
