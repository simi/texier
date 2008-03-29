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
    assert_output '<ol><li>one</li><li>two</li></ol>', "1) one\n2) two"
    assert_output(
      '<ol style="list-style-type: upper-roman"><li>one</li><li>two</li></ol>',
      "I. one\nII. two"
    )
    assert_output(
      '<ol style="list-style-type: upper-roman"><li>one</li><li>two</li></ol>',
      "I) one\nII) two"
    )
    assert_output(
      '<ol style="list-style-type: lower-alpha"><li>one</li><li>two</li></ol>',
      "a) one\nb) two"
    )
    assert_output(
      '<ol style="list-style-type: upper-alpha"><li>one</li><li>two</li></ol>',
      "A) one\nB) two"
    )
  end

  def test_ordered_list_with_arabic_numeral_with_dot_style_should_start_with_number_one
    assert_output '<ol><li>one</li><li>two</li></ol>', "1. one\n2. two"
    assert_output "<p>2. one\n3. two</p>", "2. one\n3. two"
  end

  def test_list_item_styles_in_one_list_should_not_be_mixed
    assert_output '<ul><li>one</li></ul><ul><li>two</li></ul>', "- one\n+ two"
  end

  def test_list_with_modifier
    assert_output(
      '<ul class="foo"><li>one</li><li>two</li></ul>',
      ".[foo]\n- one\n- two"
    )
  end

  def test_list_item_with_modifier
    assert_output(
      '<ul><li class="foo">one</li><li>two</li></ul>',
      "-one .[foo]\n-two"
    )
  end

  def test_definition_list
    assert_output(
      '<dl><dt>metasyntactic variables</dt><dd>foo</dd><dd>bar</dd></dl>',
      "metasyntactic variables:\n - foo\n - bar"
    )
  end

  def test_definition_list_with_block_content
    assert_output(
      '<dl><dt>see</dt><dd>first line<p>first paragraph</p>' \
        '<p>second paragraph</p></dd><dd>second line</dd></dl>',
      '
      see:
       - first line
         first paragraph

         second paragraph
       - second line'.unindent
    )
  end

  def test_definition_list_with_modifier
    assert_output(
      '<dl class="foo"><dt>numbers</dt><dd>one</dd><dd>two</dd></dl>',
      "numbers: .[foo]\n - one\n - two"
    )
  end

  def test_definition_list_definition_with_modifier
    assert_output(
      '<dl><dt>numbers</dt><dd class="foo">one</dd><dd>two</dd></dl>',
      "numbers:\n - one .[foo]\n - two"
    )
  end
end