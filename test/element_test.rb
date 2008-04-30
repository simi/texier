require "#{File.dirname(__FILE__)}/test_helper"
require 'element'

# Test case for Texier::Element class
class Texier::ElementTest < Test::Unit::TestCase
  def test_has_children_should_return_false_if_content_is_nil
    element = Texier::Element.new('foo')
    
    assert !element.has_children?
  end
  
  def test_array_containing_only_strings_should_be_joined_when_assigned_to_content
    element = Texier::Element.new('em')
    
    element.content = ['foo', 'bar']
    assert_equal 'foobar', element.content
  end
  
  def test_attributes_should_be_accessible_as_methods
    element = Texier::Element.new('foo')	
    assert_nil element.bar
	
    element.bar = 'bar'
    assert_equal 'bar', element.bar	
    assert_equal 'bar', element.attributes['bar']
  end
  
  def test_add_class_name_should_ignore_nil_argument
    element = Texier::Element.new('em')
    element.add_class_name(nil)
    
    assert_equal [], element.class_name
  end
  
  def test_add_class_name_should_create_array_if_class_already_contains_string
    element = Texier::Element.new('em', 'class' => 'foo')
    element.add_class_name('bar')
    
    assert_equal ['foo', 'bar'], element.class_name
  end
  
  def test_style
    element = Texier::Element.new('em')
    element.style['color'] = 'red'
    
    assert_equal({'color' => 'red'}, element.style)
  end
  
  def test_assigning_content_should_not_modify_assigned_value
    content = ['hello', 'world']
    Texier::Element.new('em', content)
    
    assert_equal ['hello', 'world'], content
  end
end
