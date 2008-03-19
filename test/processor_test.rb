require "#{File.dirname(__FILE__)}/test_helper"
require "processor"

# Test case for Texier::Processor class
class ProcessorTest < Test::Unit::TestCase
  def test_dom_of_new_processor_should_be_nil
    processor = Texier::Processor.new
    
    assert_nil processor.dom
  end
end
