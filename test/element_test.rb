require "#{File.dirname(__FILE__)}/test_helper"
require 'element'

# Test case for Texier::Element class
class ElementTest < Test::Unit::TestCase
  def test_append_child
    parent = Texier::Element.new(:parent)
    child = Texier::Element.new(:child)
    
    parent << child
    
    assert_not_nil parent.content
    assert_equal 1, parent.content.size
    assert_equal :child, parent.content[0].name
  end
  
  def test_has_children_should_return_false_if_content_is_nil
    element = Texier::Element.new(:foo)
    
    assert !element.has_children?
  end
  
  def test_has_children_should_return_false_if_content_is_string
    element = Texier::Element.new(:foo, 'hello world')
    
    assert !element.has_children?
  end
  
  def test_has_children_should_return_false_if_content_is_empty_array
    element = Texier::Element.new(:foo, [])
    
    assert !element.has_children?
  end
  
  def test_has_children_should_return_true_if_element_contains_at_least_one_child
    element = Texier::Element.new(:parent)
    element << Texier::Element.new(:child)
    
    assert element.has_children?
  end
end
