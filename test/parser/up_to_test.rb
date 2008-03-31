require "#{File.dirname(__FILE__)}/../test_helper"

class UpToTest < Test::Unit::TestCase
  def test_up_to
    parser = e(/[a-z]*/).up_to('bar')
    
    assert_nil parser.parse('foo')
    assert_nil parser.parse('foo42bar')
    
    assert_equal ['foo', 'bar'], parser.parse('foobar')
  end
  
  def test_one_or_more_up_to
    parser = e(/[a-z]{3}/).one_or_more.up_to('foo')
    
    assert_nil parser.parse('')
    assert_nil parser.parse('barbarbar')
    assert_nil parser.parse('foo')
    
    assert_equal ['bar', 'gaz', 'foo'], parser.parse('bargazfoo')
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
