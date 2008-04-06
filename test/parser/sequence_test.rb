require "#{File.dirname(__FILE__)}/../test_helper"

class Texier::Parser::SequenceTest < Test::Unit::TestCase
  def test_sequence
    parser = e('foo') & e('bar')
    
    assert_nil parser.parse('')
    assert_nil parser.parse('gaz')
    assert_nil parser.parse('foo')
    assert_nil parser.parse('bar')
    assert_equal ['foo', 'bar'], parser.parse('foobar')
  end
  
  def test_sequence_should_return_result_as_flat_array
    parser = e('a') & e('b') & e('c')
    
    assert_equal ['a', 'b', 'c'], parser.parse('abc')
  end

  def test_sequence_of_sequences
    parser = e('a') & (e('b') & e('c'))
    
    assert_equal ['a', 'b', 'c'], parser.parse('abc')
  end
end
