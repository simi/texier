require "#{File.dirname(__FILE__)}/../test_helper"

class Texier::Parser::IndentedTest < Test::Unit::TestCase
  def test_indented
    parser = e("foo\n") & e("bar\n").indented & e('gaz')

    assert_nil parser.parse("foo\nbar\ngaz")
    assert_equal ["foo\n", "bar\n", 'gaz'], parser.parse("foo\n bar\ngaz")
    assert_equal ["foo\n", "bar\n", 'gaz'], parser.parse("foo\n  bar\ngaz")
  end

  def test_indented_should_accept_also_unindented_empty_line
    parser = e(/[a-z]*\n/).one_or_more.indented

    assert_equal ["foo\n", "\n", "bar\n"], parser.parse(" foo\n\n bar\n")
  end

  def test_indented_with_custom_indent_pattern
    parser = e("foo\n") & e("bar\n").indented(/^\*/) & e('gaz')

    assert_nil parser.parse("foo\nbar\ngaz")
    assert_equal ["foo\n", "bar\n", 'gaz'], parser.parse("foo\n*bar\ngaz")
  end

  def test_indented_with_custom_indent_pattern_should_accept_also_unindented_empty_line
    parser = e(/[a-z]*\n/).one_or_more.indented(/^\*( |$)/)

    assert_equal ["foo\n", "\n", "bar\n"], parser.parse("* foo\n*\n* bar\n")
  end
end
