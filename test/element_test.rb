require "#{File.dirname(__FILE__)}/test_helper"
require 'element'

# Test case for Texier::Element class
class Texier::ElementTest < Test::Unit::TestCase
  def test_append_child
    parent = Texier::Element.new('parent')
    child = Texier::Element.new('child')
    
    parent << child
    
    assert_not_nil parent.content
    assert_equal 1, parent.content.size
    assert_equal 'child', parent.content[0].name
  end
  
  def test_has_children_should_return_false_if_content_is_nil
    element = Texier::Element.new('foo')
    
    assert !element.has_children?
  end
  
  def test_has_children_should_return_false_if_content_is_string
    element = Texier::Element.new('foo', 'hello world')
    
    assert !element.has_children?
  end
  
  def test_has_children_should_return_false_if_content_is_empty_array
    element = Texier::Element.new('foo', [])
    
    assert !element.has_children?
  end
  
  def test_has_children_should_return_true_if_element_contains_at_least_one_child
    element = Texier::Element.new('parent')
    element << Texier::Element.new('child')
    
    assert element.has_children?
  end
  
  def test_child_count_should_be_zero_if_content_is_nil
    assert_equal 0, Texier::Element.new('div').child_count
  end
  
  def test_child_count_should_be_zero_if_content_is_string
    assert_equal 0, Texier::Element.new('div', 'foo').child_count
  end

  def test_child_count_should_be_one_if_content_is_element
    element = Texier::Element.new('div', Texier::Element.new('div'))
    assert_equal 1, element.child_count
  end

  def test_child_count_should_be_equal_to_number_of_items_in_content_if_it_is_array
    element = Texier::Element.new('div')
    assert_equal 0, element.child_count
    
    element << Texier::Element.new('div')
    assert_equal 1, element.child_count
    
    element << Texier::Element.new('div')
    assert_equal 2, element.child_count
  end
  
  def test_array_or_strings_assigned_as_content_should_be_joined_into_single_string
    element = Texier::Element.new('foo')
    element.content = ['hello', ' ', 'world']
    
    assert_equal 'hello world', element.content
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
end
