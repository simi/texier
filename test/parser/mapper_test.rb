require "#{File.dirname(__FILE__)}/../test_helper"

class MapperTest < Test::Unit::TestCase
  def test_mapper
    parser = e('foo') do
      'bar'
    end
    
    assert_nil parser.parse('')
    assert_nil parser.parse('bar')
    assert_equal ['bar'], parser.parse('foo')
  end
  
  def test_mapper_returing_hash
    parser = e('foo') do
      {:foo => :bar}
    end
    
    assert_equal [{:foo => :bar}], parser.parse('foo')
  end
end
