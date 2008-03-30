require "#{File.dirname(__FILE__)}/../test_helper"

class ExpressionTest < Test::Unit::TestCase
  def test_create_expression_from_string
    assert_nothing_raised do 
      created = e('foo')
      assert_kind_of Texier::Parser::String, created
    end
  end
  
  def test_create_expression_from_regexp
    assert_nothing_raised do 
      created = e(/foo|bar/)
      assert_kind_of Texier::Parser::Regexp, created
    end
  end
  
  def test_create_expression_from_expression
    original = e('foo')
    
    assert_nothing_raised do 
      created = e(original)      
      assert_same original, created 
    end
  end
  
  def test_group
    parser = (e('a') & e('b')).group & e('c')
    
    assert_equal [['a', 'b'], 'c'], parser.parse('abc')
  end
  
  def test_skip
    parser = e('foo').skip
    
    assert_nil parser.parse('')
    assert_nil parser.parse('bar')
    assert_equal [], parser.parse('foo')
  end
end