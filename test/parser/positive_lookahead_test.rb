require "#{File.dirname(__FILE__)}/../test_helper"

class Texier::Parser::PositiveLookaheadTest < Test::Unit::TestCase
  def test_positive_lookahead
    parser = e('foo') & +e('bar')
    
    assert_nil parser.parse('foo')
    assert_nil parser.parse('foogaz')
    assert_equal ['foo'], parser.parse('foobar')
  end
end
