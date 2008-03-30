require "#{File.dirname(__FILE__)}/../test_helper"

class RepetitionWithSeparatorTest < Test::Unit::TestCase
  def test_zero_or_more_repetition_with_separator
    parser = e('foo').zero_or_more.separated_by('-')
    
    assert_equal [], parser.parse('')
    assert_equal ['foo'], parser.parse('foo')
    assert_equal ['foo', 'foo'], parser.parse('foo-foo')
  end
  
  def test_repetition_with_separator_should_not_consume_last_separator
    parser = e('foo').zero_or_more.separated_by('-') & '-bar'

    assert_equal ['-bar'], parser.parse('-bar')
    assert_equal ['foo', '-bar'], parser.parse('foo-bar')
  end
end
