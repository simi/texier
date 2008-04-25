require "#{File.dirname(__FILE__)}/../test_helper"

class Texier::Parser::StringTest < Test::Unit::TestCase
  def test_string
    parser = e('hello world')
    
    assert_nil parser.parse('')
    assert_nil parser.parse('goodbye world')    
    assert_equal ['hello world'], parser.parse('hello world')
  end
  
  def test_string_should_be_multibyte_safe
    parser = e('您好') & e('world')
    
    assert_equal ['您好', 'world'], parser.parse('您好world')
  end
end
