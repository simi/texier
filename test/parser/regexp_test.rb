require "#{File.dirname(__FILE__)}/../test_helper"

class Texier::Parser::RegexpTest < Test::Unit::TestCase
  def test_regexp
    parser = e(/hello.*world/)
    
    assert_nil parser.parse('')
    assert_nil parser.parse('goodby world')
    assert_equal ['hello world'], parser.parse('hello world')
    assert_equal ['hello---world'], parser.parse('hello---world')
  end
end
