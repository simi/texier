require "#{File.dirname(__FILE__)}/../test_helper"

class StringTest < Test::Unit::TestCase
  def test_string
    parser = e('hello world')
    
    assert_nil parser.parse('')
    assert_nil parser.parse('goodbye world')    
    assert_equal ['hello world'], parser.parse('hello world')
  end
end
