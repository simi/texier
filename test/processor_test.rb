require "#{File.dirname(__FILE__)}/test_helper"
require "processor"

# Test case for Texier::Processor class
class ProcessorTest < Test::Unit::TestCase
  def test_dom_of_new_processor_should_be_nil
    processor = Texier::Processor.new
    
    assert_nil processor.dom
  end
  
  def test_dom_should_contain_document_element_after_calling_process
    processor = Texier::Processor.new
    processor.process('hello world')
    
    assert_not_nil processor.dom 
    assert_equal :document, processor.dom.name
  end
end
