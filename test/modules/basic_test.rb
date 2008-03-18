require "#{File.dirname(__FILE__)}/../test_helper"
require 'processor'

# Test case for Texier::Modules::Basic class
class BasicTest < Test::Unit::TestCase
  def test_empty_input_should_produce_dom_with_empty_root_element
    processor = Texier::Processor.new
    processor.process('')
    
    dom = processor.dom
    
    assert_equal :document, dom.name
    assert_nil dom.content
  end

  def test_empty_input_should_produce_empty_output
    assert_equal '', Texier.process('')
  end
  
  def test_single_paragraph
    assert_equal '<p>hello world</p>', Texier.process('hello world')
  end
end
