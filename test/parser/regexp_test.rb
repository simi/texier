require "#{File.dirname(__FILE__)}/../test_helper"

class Texier::Parser::RegexpTest < Test::Unit::TestCase
  def test_regexp
    parser = e(/hello.*world/)
    
    assert_nil parser.parse('')
    assert_nil parser.parse('goodbye world')
    assert_equal ['hello world'], parser.parse('hello world')
    assert_equal ['hello---world'], parser.parse('hello---world')
  end
  
  def test_regexp_with_captures
    parser = e(/(hello).*(world)/)
    assert_equal ['hello', 'world'], parser.parse('hello world')
    
    parser = e(/(hello).*(?:world)/)
    assert_equal ['hello'], parser.parse('hello world')
    
    parser = e(/(hello).*\(world\)/)
    assert_equal ['hello'], parser.parse('hello (world)')
  end
end
