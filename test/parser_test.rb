require "#{File.dirname(__FILE__)}/test_helper"
require 'parser'

# Test case for Texier::Parser class
class ParserTest < Test::Unit::TestCase
  def setup
    @parser = Texier::Parser.new
    @parser.start = :document
  end
  
  def test_calling_undefined_method_should_create_new_rule
    assert_kind_of Texier::Parser::Rule, @parser.foo
  end
  
  def test_parse_string
    @parser.define do
      document.is 'hello world'
    end
    
    assert_nil @parser.parse('')
    assert_nil @parser.parse('goodbye world')
    
    assert_equal 'hello world', @parser.parse('hello world')
  end
end
