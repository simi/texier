require "#{File.dirname(__FILE__)}/../test_helper"

# Test case for Texier::Modules::List class
class ListTest < Test::Unit::TestCase
  def test_simple_list
    assert_output(
      '<ul><li>one</li><li>two</li><li>three</li></ul>',
      "- one\n- two\n- three"
    )
  end
  
  def test_list_item_with_block_content
    assert_output(
      "<ul><li>first line<p>first paragraph</p>" \
        "<p>second paragraph\nthis one spans two lines</p></li>" \
        "<li>inline content</li></ul>",
      
      '
      - first line

        first paragraph

        second paragraph
        this one spans two lines
      - inline content'.unindent
    )
  end
  
  def test_nested_list
    assert_output(
      '<ul><li>one</li><li>two<ul><li>two one</li><li>two two</li>' \
        '<li>two three</li></ul></li><li>three</li></ul>',

      '
      - one
      - two
          - two one
          - two two
          - two three
      - three'.unindent
    )
  end
  
  def test_unordered_list_styles
    assert_output '<ul><li>one</li><li>two</li></ul>', "- one\n- two"
    assert_output '<ul><li>one</li><li>two</li></ul>', "-one\n-two"
    assert_output '<ul><li>one</li><li>two</li></ul>', "+ one\n+ two"
    assert_output '<ul><li>one</li><li>two</li></ul>', "* one\n* two"
  end
  
  def test_ordered_list_styles
    assert_output '<ol><li>one</li><li>two</li></ol>', "1. one\n2. two"
  end
  
  def test_ordered_list_with_arabic_numeral_with_dot_style_should_start_with_number_one
    assert_output '<ol><li>one</li><li>two</li></ol>', "1. one\n2. two"
    assert_output "<p>2. one\n3. two</p>", "2. one\n3. two"
  end
  
  def test_list_item_styles_in_one_list_should_not_be_mixed
    assert_output '<ul><li>one</li></ul><ul><li>two</li></ul>', "- one\n+ two"
  end
end