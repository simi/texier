require "#{File.dirname(__FILE__)}/test_helper"
require 'renderer'
require 'element'

# Test case for Texier::Renderer class
class RendererTest < Test::Unit::TestCase
  def setup
    @renderer = Texier::Renderer.new
  end
  
  def test_empty_element_should_be_rendered_as_empty_string
    assert_equal '', @renderer.render(nil)
    assert_equal '', @renderer.render('')
    assert_equal '', @renderer.render([])
  end
  
  def test_string_should_be_rendered_as_itself
    assert_equal 'hello world', @renderer.render('hello world')
  end
  
  def test_array_should_be_rendered_as_concatenation_of_renderings_of_its_items
    assert_equal 'foobar', @renderer.render(['foo', 'bar'])
  end
  
  def test_element_should_be_rendered_with_tags
    element = Texier::Element.new(:foo, 'hello world')
    
    assert_equal '<foo>hello world</foo>', @renderer.render(element)
  end
  
  def test_element_with_simple_attribute
    element = Texier::Element.new(:foo, 'hello', :class => 'bar')
    
    assert_equal '<foo class="bar">hello</foo>', @renderer.render(element)
  end
end
