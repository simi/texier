require "#{File.dirname(__FILE__)}/../test_helper"

class NegativeLookaheadTest < Test::Unit::TestCase
  def test_negative_lookahead
    parser = -e('foo') & e(/[a-z]{3}/)
    
    assert_nil parser.parse('')
    assert_nil parser.parse('foo')
    assert_equal ['bar'], parser.parse('bar')
  end
end
