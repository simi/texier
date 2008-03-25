require "#{File.dirname(__FILE__)}/../test_helper"

# Test case for Texier::Modules::Modifier class
class ModifierTest < Test::Unit::TestCase
  def test_title
    assert_output '<p><em title="foo">hello</em></p>', '*hello .(foo)*'
    assert_output '<p><em title="foo">hello</em></p>', '*hello .( foo  )*'
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
  
  def test_horizontal_align
    assert_output(
      '<p style="text-align: left">hello world</p>',
      ".<\nhello world"
    )
  end
  
  def test_many_modifiers
    assert_output(
      '<p><em class="foo" title="blah">hello</em></p>',
      '*hello .[foo](blah)*'
    )
  end
  
  def test_when_there_is_more_than_one_title_modifier_only_the_last_one_should_be_applied
    assert_output(
      '<p><em title="bar">hello</em></p>',
      '*hello .(foo)(bar)*'
    )
  end
  
  def test_when_there_is_more_than_one_class_modifier_they_should_be_concatenated
    assert_output(
      '<p><em class="foo bar">hello</em></p>',
      '*hello .[foo][bar]*'
    )
  end
  
  def test_when_there_is_more_than_one_style_modifier_they_should_be_merged
    assert_output(
      '<p><em style="font-family: sans-serif; color: black">hello</em></p>',
      '*hello .{font-family: sans-serif}{color: black}*'
    )
  end
  
end
