require "#{File.dirname(__FILE__)}/../test_helper"

class Texier::Parser::LazySequenceTest < Test::Unit::TestCase
  def test_lazy_sequence_with_repetition
    parser = e(/[a-z]{3}/).one_or_more.up_to('bar')
    
    assert_nil parser.parse('')
    assert_nil parser.parse('foo')
    assert_nil parser.parse('bar')
    
    assert_equal ['foo', 'bar'], parser.parse('foobar')
  end
end
