require "#{File.dirname(__FILE__)}/../test_helper"

# Test case for Texier::Modules::BlockQuote class
class BlockQuoteTest < Test::Unit::TestCase
  def test_single_line_block_quote
    assert_output(
      '<blockquote><p>hello world</p></blockquote>',
      '> hello world'
    )
  end
  
  def test_multiline_block_quote
    assert_output(
      "<blockquote><p>first line\nsecond line</p></blockquote>",
      "> first line\n> second line"
    )
  end
  
  def test_block_quote_with_many_block_elements
    assert_output(
      '<blockquote><p>first paragraph</p><p>second paragraph</p></blockquote>',
      '
      > first paragraph
      >
      > second paragraph'.unindent
    )
  end
  
  def test_nested_block_quotes
    assert_output(
      '<blockquote><p>first paragraph</p>' \
        '<blockquote><p>nested paragraph</p></blockquote>' \
        '<p>last paragraph</p></blockquote>',
      '
      > first paragraph
      > > nested paragraph
      > last paragraph'.unindent
    )
  end
end
