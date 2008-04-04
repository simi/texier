require "#{File.dirname(__FILE__)}/../test_helper"

# Test case for class Texier::Modules::HorizLine
class HorizLineTest < Test::Unit::TestCase
  def test_module_name_should_be_horiz_line
    processor = Texier::Processor.new
    
    assert_nothing_raised do 
      assert_instance_of(
        Texier::Modules::HorizLine, processor.horiz_line_module
      )
    end
  end
  
  def test_horiz_line
    assert_output '<hr />', '--------'
    assert_output '<hr />', '********'
  end
  
  def test_horiz_line_with_paragraph
    assert_output(
      '<p>hello world</p><hr />',
      "hello world\n\n---"
    )
  end
end
