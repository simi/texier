require "#{File.dirname(__FILE__)}/../test_helper"

class Texier::Parser::EverythingUpToTest < Test::Unit::TestCase
  def test_everything_up_to
    parser = everything_up_to('bar')
    
    assert_nil parser.parse('')
    assert_equal ['', 'bar'], parser.parse('bar')
    assert_equal ['foo', 'bar'], parser.parse('foobar')
  end
  
  def test_quoted_text
    parser = quoted_text('"')
    
    assert_nil parser.parse('')
    assert_nil parser.parse('foo')
    
    assert_equal ['foo'], parser.parse('"foo"')
  end
  
  def test_quoted_text_with_different_opening_and_closing_quotes
    parser = quoted_text('[', ']')
    
    assert_equal ['foo'], parser.parse('[foo]')
  end
end
