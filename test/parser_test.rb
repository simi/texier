require "#{File.dirname(__FILE__)}/test_helper"

# Test case for Texier::Parser class
class ParserTest < Test::Unit::TestCase
  include Texier::Parser::Generators
  
  def setup
    @parser = Texier::Parser.new
  end
  
  def test_parser_should_raise_exception_if_no_starting_symbol_is_defined
    assert_raise(Texier::Error) do
      @parser.parse('foo')
    end
  end
  
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
  
  def test_string_expression_should_match_only_that_string
    @parser[:document] = e('hello world')
    
    assert_nil @parser.parse('')
    assert_nil @parser.parse('goodbye world')    
    assert_equal ['hello world'], @parser.parse('hello world')
  end
  
  def test_regexp_expression_should_match_when_its_regexp_matches
    @parser[:document] = e(/hello.*world/)
    
    assert_nil @parser.parse('')
    assert_nil @parser.parse('goodby world')
    assert_equal ['hello world'], @parser.parse('hello world')
    assert_equal ['hello---world'], @parser.parse('hello---world')
  end
  
  def test_choice
    @parser[:document] = e('foo') | e('bar')
    
    assert_nil @parser.parse('')
    assert_nil @parser.parse('hello world')
    
    assert_equal ['foo'], @parser.parse('foo')
    assert_equal ['bar'], @parser.parse('bar')
  end
    
  def test_sequence
    @parser[:document] = e('foo') & e('bar')
    
    assert_nil @parser.parse('')
    assert_nil @parser.parse('gaz')
    assert_nil @parser.parse('foo')
    assert_nil @parser.parse('bar')
    assert_equal ['foo', 'bar'], @parser.parse('foobar')
  end
  
  def test_sequence_should_return_result_as_flat_array
    @parser[:document] = e('a') & e('b') & e('c')
    
    assert_equal ['a', 'b', 'c'], @parser.parse('abc')
  end

  def test_sequence_of_sequences
    @parser[:document] = e('a') & (e('b') & e('c'))
    assert_equal ['a', 'b', 'c'], @parser.parse('abc')
  end
  
  def test_maybe
    @parser[:document] = e('foo').maybe
    
    assert_equal [nil], @parser.parse('')
    assert_equal ['foo'], @parser.parse('foo')
  end
  
  def test_zero_or_more_repetition
    @parser[:document] = e('foo').zero_or_more

    assert_equal [], @parser.parse('')
    assert_equal ['foo'], @parser.parse('foo')
    assert_equal ['foo', 'foo'], @parser.parse('foofoo')
  end
  
  def test_one_or_more_repetition
    @parser[:document] = e('foo').one_or_more
    
    assert_nil @parser.parse('')
    assert_equal ['foo'], @parser.parse('foo')
    assert_equal ['foo', 'foo'], @parser.parse('foofoo')
  end
  
  def test_zero_or_more_repetition_with_separator
    @parser[:document] = e('foo').zero_or_more.separated_by('-')
    
    assert_equal [], @parser.parse('')
    assert_equal ['foo'], @parser.parse('foo')
    assert_equal ['foo', 'foo'], @parser.parse('foo-foo')
  end
  
  def test_repetition_with_separator_should_not_consume_last_separator
    @parser[:document] = e('foo').zero_or_more.separated_by('-') & '-bar'

    assert_equal ['-bar'], @parser.parse('-bar')
    assert_equal ['foo', '-bar'], @parser.parse('foo-bar')
  end
  
  def test_mapper
    @parser[:document] = e('foo') do
      'bar'
    end
    
    assert_nil @parser.parse('')
    assert_nil @parser.parse('bar')
    assert_equal ['bar'], @parser.parse('foo')
  end
  
  def test_mapper_returing_hash
    @parser[:document] = e('foo') do
      {:foo => :bar}
    end
    
    assert_equal [{:foo => :bar}], @parser.parse('foo')
  end
  
  def test_everything_up_to
    @parser[:document] = everything_up_to('bar')
    
    assert_nil @parser.parse('')
    assert_nil @parser.parse('foo')
    assert_nil @parser.parse('bar')
    assert_equal ['foo', 'bar'], @parser.parse('foobar')
  end
  
  def test_one_or_more_up_to
    @parser[:document] = e(/[a-z]{3}/).one_or_more.up_to('foo')
    
    assert_nil @parser.parse('')
    assert_nil @parser.parse('barbarbar')
    assert_nil @parser.parse('foo')
    
    assert_equal [['bar', 'gaz'], 'foo'], @parser.parse('bargazfoo')
  end
  
  def test_group
    @parser[:document] = (e('a') & e('b')).group & e('c')
    
    assert_equal [['a', 'b'], 'c'], @parser.parse('abc')
  end
  
  def test_skip
    @parser[:document] = e('foo').skip
    
    assert_nil @parser.parse('')
    assert_nil @parser.parse('bar')
    assert_equal [], @parser.parse('foo')
  end
  
  def test_quoted_text
    @parser[:document] = quoted_text('"')
    
    assert_nil @parser.parse('')
    assert_nil @parser.parse('foo')
    
    assert_equal ['foo'], @parser.parse('"foo"')
  end
  
  def test_quoted_text_with_different_opening_and_closing_quotes
    @parser[:document] = quoted_text('[', ']')
    
    assert_equal ['foo'], @parser.parse('[foo]')
  end
  
  def test_indented
    @parser[:document] = e("foo\n") & indented("bar\n") & e('gaz')
    
    assert_nil @parser.parse("foo\nbar\ngaz")
    assert_equal ["foo\n", "bar\n", 'gaz'], @parser.parse("foo\n bar\ngaz")
    assert_equal ["foo\n", "bar\n", 'gaz'], @parser.parse("foo\n  bar\ngaz")
  end
  
  def test_indented_should_accept_also_unindented_empty_line
    @parser[:document] = indented(e(/[a-z]*\n/).one_or_more)
    
    assert_equal ["foo\n", "\n", "bar\n"], @parser.parse(" foo\n\n bar\n")
  end
  
  def test_indented_with_custom_indent_pattern
    @parser[:document] = e("foo\n") & indented("bar\n", /^\*/) & e('gaz')
    
    assert_nil @parser.parse("foo\nbar\ngaz")
    assert_equal ["foo\n", "bar\n", 'gaz'], @parser.parse("foo\n*bar\ngaz")
  end
  
  def test_indented_with_custom_indent_pattern_should_accept_also_unindented_empty_line
    @parser[:document] = indented(e(/[a-z]*\n/).one_or_more, /^\*( |$)/)
    
    assert_equal ["foo\n", "\n", "bar\n"], @parser.parse("* foo\n*\n* bar\n")
  end
  
  def test_positive_lookahead
    @parser[:document] = e('foo') & +e('bar')
    
    assert_nil @parser.parse('foo')
    assert_nil @parser.parse('foogaz')
    assert_equal ['foo'], @parser.parse('foobar')
  end
  
  def test_negative_lookahead
    @parser[:document] = -e('foo') & e(/[a-z]{3}/)
    
    assert_nil @parser.parse('')
    assert_nil @parser.parse('foo')
    assert_equal ['bar'], @parser.parse('bar')
  end
end