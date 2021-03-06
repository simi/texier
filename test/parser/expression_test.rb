require "#{File.dirname(__FILE__)}/../test_helper"

class Texier::Parser::ExpressionTest < Test::Unit::TestCase
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
end