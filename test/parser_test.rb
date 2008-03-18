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
  
  def test_has_rule_should_return_false_if_rule_is_not_yet_defined
    assert !@parser.has_rule?(:foo)
  end
  
  def test_has_rule_should_return_true_if_rule_is_already_defined
    @parser.define do
      foo.is 'foo'
    end
    
    assert @parser.has_rule?(:foo)   
  end
  
  def test_create_rule_from_string
    assert_nothing_raised do 
      Texier::Parser::Rule.create('hello world')
    end
  end
  
  def test_create_rule_from_regexp
    assert_nothing_raised do 
      Texier::Parser::Rule.create(/hello.*world/)
    end
  end
  
  def test_create_rule_from_rule
    assert_nothing_raised do 
      Texier::Parser::Rule.create(
        Texier::Parser::StringRule.new('hello world')
      )
    end
  end
  
  def test_empty_rule_should_not_match_anything
    @parser.define do
      document # empty rule
    end
    
    assert_nil @parser.parse('')
    assert_nil @parser.parse('hello world')
  end
  
  def test_string_rule_should_match_only_that_string
    @parser.define do
      document.is 'hello world'
    end
    
    assert_nil @parser.parse('')
    assert_nil @parser.parse('goodbye world')    
    assert_equal 'hello world', @parser.parse('hello world')
  end
  
  def test_regexp_rule_should_match_when_its_regexp_matches
    @parser.define do
      document.is(/hello.*world/)      
    end
    
    assert_nil @parser.parse('')
    assert_nil @parser.parse('goodby world')
    assert_equal 'hello world', @parser.parse('hello world')
    assert_equal 'hello---world', @parser.parse('hello---world')
  end
  
  def test_choice
    @parser.define do
      document.is 'foo'
      document.is 'bar'
    end
    
    assert_nil @parser.parse('')
    assert_nil @parser.parse('hello world')
    
    assert_equal 'foo', @parser.parse('foo')
    assert_equal 'bar', @parser.parse('bar')
  end
  
  def test_sequence
    @parser.define do
      document.is 'foo', 'bar'
    end
    
    assert_nil @parser.parse('')
    assert_nil @parser.parse('gaz')
    assert_nil @parser.parse('foo')
    assert_nil @parser.parse('bar')
    assert_equal ['foo', 'bar'], @parser.parse('foobar')
  end
  
  def test_zero_or_more_repetition
    @parser.define do
      document.is zero_or_more('foo')
    end

    assert_equal [], @parser.parse('')
    assert_equal ['foo'], @parser.parse('foo')
    assert_equal ['foo', 'foo'], @parser.parse('foofoo')
  end
  
  def test_one_or_more_repetition
    @parser.define do
      document.is one_or_more('foo')
    end
    
    assert_nil @parser.parse('')
    assert_equal ['foo'], @parser.parse('foo')
    assert_equal ['foo', 'foo'], @parser.parse('foofoo')
  end
  
  def test_zero_or_more_repetition_with_separator
    @parser.define do
      document.is zero_or_more('foo').separated_by('-')
    end
    
    assert_equal [], @parser.parse('')
    assert_equal ['foo'], @parser.parse('foo')
    assert_equal ['foo', 'foo'], @parser.parse('foo-foo')
  end
  
  def test_repetition_with_separator_should_not_consume_last_separator
    @parser.define do
      document.is zero_or_more('foo').separated_by('-'), '-bar'
    end

    assert_equal [[], '-bar'], @parser.parse('-bar')
    assert_equal [['foo'], '-bar'], @parser.parse('foo-bar')
  end
  
  def test_mapper
    @parser.define do
      document.is 'foo' do
        'bar'
      end
    end
    
    assert_nil @parser.parse('')
    assert_nil @parser.parse('bar')
    assert_equal 'bar', @parser.parse('foo')
  end
  
  def test_everything_up_to
    @parser.define do
      document.is everything_up_to('bar')
    end
    
    assert_nil @parser.parse('')
    assert_nil @parser.parse('foo')
    assert_nil @parser.parse('bar')
    assert_equal 'foo', @parser.parse('foobar')
  end
end
