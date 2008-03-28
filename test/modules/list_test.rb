require "#{File.dirname(__FILE__)}/../test_helper"

# Test case for Texier::Modules::List class
class ListTest < Test::Unit::TestCase
  def test_simple_list
    assert_output(
      '<ul><li>one</li><li>two</li><li>three</li></ul>',
      '
      - one
      - two
      - three'.unindent
    )
  end
  
  def test_list_item_with_one_block_content
    assert_output(
      "<ul><li><p>first paragraph</p><p>second paragraph</p>" \
        "<p>third paragraph\nthis one spans two lines</p></li>" \
        "<li>inline content</li></ul>",
      
      '
      - first paragraph

        second paragraph

        third paragraph
        this one spans two lines
      - inline content'.unindent
    )
  end
  
  def test_nested_list
    assert_output(
      '<ul><li>one</li><li><p>two</p><ul><li>two one</li><li>two two</li>' \
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
end