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
  
  def test_list_item_with_block_content
    assert_output(
      '<ul><li>inline content<p>block content</p></li><li>another inline content</li></ul>',
      
      '
      - inline content

        block content
      - another inline content'.unindent
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
end