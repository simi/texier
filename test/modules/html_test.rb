require "#{File.dirname(__FILE__)}/../test_helper"

# Test case for Texier::Modules::Html
class HtmlTest < Test::Unit::TestCase
  def test_inline_html_element
    assert_output '<p><em>hello</em></p>', '<em>hello</em>'
  end
  
  def test_block_html_element
    assert_output '<div>hello</div>', '<div>hello</div>'
  end
  
  def test_block_html_element_with_block_content
    assert_output '<div><p>hello</p></div>', "<div>\n\nhello\n\n</div>"
  end
  
  def test_nested_block_html_elements
    assert_output '<div><div>hello</div></div>', '<div><div>hello</div></div>'
  end
  
  def test_attributes
    assert_output '<div class="foo">hello</div>', '<div class="foo">hello</div>'
  end
  
  def test_unquoted_attribute_value
    assert_output '<div class="foo">hello</div>', '<div class=foo>hello</div>'
  end
  
  def test_many_attributes
    assert_output(
      '<div class="foo" id="bar">hello</div>',
      '<div class="foo" id="bar">hello</div>'
    )
  end
end
