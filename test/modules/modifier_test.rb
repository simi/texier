require "#{File.dirname(__FILE__)}/../test_helper"

# Test case for Texier::Modules::Modifier class
class ModifierTest < Test::Unit::TestCase
  def test_modifier_should_be_optional
    assert_output '<p><em>hello</em></p>', '*hello*'
  end
  
  def test_title
    assert_output '<p><em title="foo">hello</em></p>', '*hello .(foo)*'
  end
  
  def test_class
    assert_output '<p><em class="foo">hello</em></p>', '*hello .[foo]*'
  end
  
  def test_many_classes
    assert_output '<p><em class="foo bar">hello</em></p>', '*hello .[foo bar]*'
    assert_output '<p><em class="foo bar">hello</em></p>', '*hello .[foo   bar]*'
  end
  
  def test_id
    assert_output '<p><em id="foo">hello</em></p>', '*hello .[#foo]*'
  end
  
  def test_class_and_id
    assert_output(
      '<p><em class="foo" id="bar">hello</em></p>', 
      '*hello .[foo #bar]*'
    )
  end
  
  def test_styles
    assert_output(
      '<p><em style="font-family: sans-serif">hello</em></p>',
      '*hello .{font-family: sans-serif}*'
    )
    
    assert_output(
      '<p><em style="font-family: sans-serif; color: green">hello</em></p>',
      '*hello .{font-family: sans-serif; color: green}*'
    )
  end
end
