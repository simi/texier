require "#{File.dirname(__FILE__)}/test_helper"
require 'renderer'
require 'element'

# Test case for Texier::Renderer class
class RendererTest < Test::Unit::TestCase
  def setup
    @renderer = Texier::Renderer.new
  end
  
  def test_dom_with_empty_document_element_should_be_rendered_as_empty_string
    dom = Texier::Element.new(:document)
    
    assert_equal '', @renderer.render(dom)
  end
  
  def test_dom_with_one_child_element
    dom = Texier::Element.new(:document)
    dom << Texier::Element.new(:paragraph, 'hello world')
    
    assert_equal '<paragraph>hello world</paragraph>', @renderer.render(dom)
  end
end
