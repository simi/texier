require "#{File.dirname(__FILE__)}/../test_helper"

class Texier::Parser::ChoiceTest < Test::Unit::TestCase
  def test_choice
    parser = e('foo') | e('bar')
    
    assert_nil parser.parse('')
    assert_nil parser.parse('hello world')
    
    assert_equal ['foo'], parser.parse('foo')
    assert_equal ['bar'], parser.parse('bar')
  end
end
