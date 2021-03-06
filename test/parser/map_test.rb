require "#{File.dirname(__FILE__)}/../test_helper"

class Texier::Parser::MapTest < Test::Unit::TestCase
  def test_map
    parser = e('foo') do
      'bar'
    end
    
    assert_nil parser.parse('')
    assert_nil parser.parse('bar')
    assert_equal ['bar'], parser.parse('foo')
  end
  
  def test_map_returing_hash
    parser = e('foo') do
      {:foo => :bar}
    end
    
    assert_equal [{:foo => :bar}], parser.parse('foo')
  end
  
  def test_map_returning_nil
    parser = e('foo') {nil}
    
    assert_nil parser.parse('foo')
  end
  
  def test_skip
    parser = e('foo').skip
    
    assert_nil parser.parse('')
    assert_nil parser.parse('bar')
    assert_equal [], parser.parse('foo')
  end
  
  def test_group
    parser = (e('a') & e('b')).group & e('c')
    
    assert_equal [['a', 'b'], 'c'], parser.parse('abc')
  end
end
