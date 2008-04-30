require "#{File.dirname(__FILE__)}/../test_helper"

# Test case for class Texier::Modules::HorizLine
class Texier::Modules::HorizLineTest < Test::Unit::TestCase
  def test_module_name_should_be_horiz_line
    texier = Texier::Base.new
    
    assert_nothing_raised do 
      assert_instance_of(
        Texier::Modules::HorizLine, texier.horiz_line_module
      )
    end
  end
  
  def test_horiz_line
    assert_equal_output '<hr />', '--------'
    assert_equal_output '<hr />', '********'
  end
  
  def test_horiz_line_with_paragraph
    assert_equal_output(
      '<p>hello world</p><hr />',
      "hello world\n\n---"
    )
  end
end
