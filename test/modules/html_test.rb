require "#{File.dirname(__FILE__)}/../test_helper"

# Test case for Texier::Modules::Html
class Texier::Modules::HtmlTest < Test::Unit::TestCase
  def test_inline_html_element
    assert_output '<p><em>hello</em></p>', '<em>hello</em>'
  end
  
  def test_inline_html_element_with_inline_content
    assert_output(
      '<p><em>hello <strong>world</strong></em></p>', 
      '<em>hello **world**</em>'
    )
  end
  
  def test_empty_inline_html_element
    assert_output '<p><img /></p>', '<img />'
  end

  def test_nested_inline_html_elements
    assert_output(
      '<p><em>hello <strong>world</strong></em></p>', 
      '<em>hello <strong>world</strong></em>'
    )
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
  
  def test_empty_block_html_element
    assert_output '<hr />', '<hr />'
  end
  
  def test_attributes
    assert_output '<div class="foo">hello</div>', '<div class="foo">hello</div>'
  end
  
  
  def test_many_attributes
    assert_output(
      '<div class="foo" id="bar">hello</div>',
      '<div class="foo" id="bar">hello</div>'
    )
  end
  
  def test_unquoted_attribute_value
    assert_output '<div class="foo">hello</div>', '<div class=foo>hello</div>'
  end
  
  def test_attribute_without_value
    assert_output(
      '<p><input disabled="disabled" /></p>', 
      '<input disabled />'
    )
  end
  
  def test_html_element_should_be_ignored_unless_it_is_allowed
    @processor = Texier::Processor.new
    @processor.allowed_tags = {'em' => :all}
    
    assert_output(
      '<p><em>i am allowed</em> &lt;strong&gt;i am not&lt;/strong&gt;</p>',
      '<em>i am allowed</em> <strong>i am not</strong>'
    )
  end
  
  def test_attribute_should_be_ignored_unless_it_is_allowed
    @processor = Texier::Processor.new
    @processor.allowed_tags = {'em' => ['class']}
    
    assert_output(
      '<p><em class="foo">hello</em></p>', 
      '<em class="foo" id="bar">hello</em>'
    )
  end
  
  def test_class_should_be_ignored_unless_it_is_allowed
    @processor = Texier::Processor.new
    @processor.allowed_classes = ['foo']
    
    assert_output(
      '<p><em class="foo">hello</em></p>', 
      '<em class="foo bar">hello</em>'
    )
  end
  
  def test_id_should_be_ignored_unless_it_is_allowed
    @processor = Texier::Processor.new
    @processor.allowed_classes = ['#foo']
    
    assert_output(
      '<p><em id="foo">hello</em> <strong>world</strong></p>', 
      '<em id="foo">hello</em> <strong id="bar">world</strong>'
    )
  end
  
  def test_style_should_be_ignored_unless_it_is_allowed
    @processor = Texier::Processor.new
    @processor.allowed_styles = ['color']
    
    assert_output(
      '<p><em style="color: blue">hello</em></p>', 
      '<em style="font-family: sans-serif; color: blue">hello</em>'
    )
  end
  
  def test_class_should_be_parsed_into_array
    @processor = Texier::Processor.new
    @processor.process('<em class="foo bar">hello</em>')
    
    element = @processor.dom[0].content[0]
    assert_instance_of Array, element.attributes['class']
  end
  
  def test_style_should_be_parsed_into_hash
    @processor = Texier::Processor.new
    @processor.process('<em style="color: red">hello</em>')
    
    element = @processor.dom[0].content[0]
    assert_instance_of Hash, element.style
  end
  
  def test_html_comment
    assert_output '<!-- comment -->', '<!-- comment -->'
  end
  
  def test_multiline_html_comment
    assert_output(
      "<!-- first line\nsecond line -->", 
      "<!-- first line\nsecond line -->"
    )
  end
  
  def test_content_of_html_comment_should_not_be_escaped
    assert_output '<!-- <img src="foo" /> -->', '<!-- <img src="foo" /> -->'
  end
  
  def test_html_comment_as_inline_element
    assert_output(
      '<p>hello <!-- comment --> world</p>',
      'hello <!-- comment --> world'
    )
  end
  
  def test_multiline_html_comment_as_inline_element
    assert_output(
      "<p>hello <!-- first line\nsecond line --> world</p>",
      "hello <!-- first line\nsecond line --> world"
    )
  end
  
  def test_comments_should_be_discarded_if_pass_comments_is_false
    @processor = Texier::Processor.new
    @processor.html_module.pass_comments = false
    
    assert_output '<p>hello world</p>', 'hello<!-- comment --> world'
  end
end
