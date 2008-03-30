require "#{File.dirname(__FILE__)}/../test_helper"

class RepetitionUpToTest < Test::Unit::TestCase
  def test_one_or_more_up_to
    parser = e(/[a-z]{3}/).one_or_more.up_to('foo')
    
    assert_nil parser.parse('')
    assert_nil parser.parse('barbarbar')
    assert_nil parser.parse('foo')
    
    assert_equal [['bar', 'gaz'], 'foo'], parser.parse('bargazfoo')
  end
end
