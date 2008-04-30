require "#{File.dirname(__FILE__)}/../test_helper"

# Test case for Texier::Modules::BlockQuote class
class Texier::Modules::BlockQuoteTest < Test::Unit::TestCase
  def test_single_line_block_quote
    assert_equal_output(
      '<blockquote><p>hello world</p></blockquote>',
      '> hello world'
    )
  end
  
  def test_multiline_block_quote
    assert_equal_output(
      "<blockquote><p>first line\nsecond line</p></blockquote>",
      "> first line\n> second line"
    )
  end
  
  def test_block_quote_with_many_block_elements
    assert_equal_output(
      '<blockquote><p>first paragraph</p><p>second paragraph</p></blockquote>',
      '
      > first paragraph
      >
      > second paragraph'.unindent
    )
  end
  
  def test_nested_block_quotes
    assert_equal_output(
      '<blockquote><p>first paragraph</p>' \
        '<blockquote><p>nested paragraph</p></blockquote>' \
        '<p>last paragraph</p></blockquote>',
      '
      > first paragraph
      > > nested paragraph
      > last paragraph'.unindent
    )
  end
  
  def test_block_quote_with_modifier
    assert_equal_output(
      '<blockquote class="foo"><p>hello world</p></blockquote>',
      ".[foo]\n> hello world"
    )
  end
  
  def test_block_quote_with_cite_link
    assert_equal_output(
      '<blockquote cite="http://metatribe.org"><p>hello world</p></blockquote>',
      "> hello world\n>:http://metatribe.org"
    )
  end
end
