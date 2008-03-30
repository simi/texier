require "#{File.dirname(__FILE__)}/../test_helper"

class MaybeTest < Test::Unit::TestCase
  def test_maybe
    parser = e('foo').maybe
    
    assert_equal [nil], parser.parse('')
    assert_equal ['foo'], parser.parse('foo')
  end
  
end
