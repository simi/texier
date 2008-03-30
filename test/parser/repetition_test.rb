require "#{File.dirname(__FILE__)}/../test_helper"

class RepetitionTest < Test::Unit::TestCase
  def test_zero_or_more_repetition
    parser = e('foo').zero_or_more

    assert_equal [], parser.parse('')
    assert_equal ['foo'], parser.parse('foo')
    assert_equal ['foo', 'foo'], parser.parse('foofoo')
  end
  
  def test_one_or_more_repetition
    parser = e('foo').one_or_more
    
    assert_nil parser.parse('')
    assert_equal ['foo'], parser.parse('foo')
    assert_equal ['foo', 'foo'], parser.parse('foofoo')
  end
end
