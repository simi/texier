require "#{File.dirname(__FILE__)}/../test_helper"

# Test case for Texier::Modules::Modifier class
class Texier::Expressions::ModifierTest < Test::Unit::TestCase
  def setup
    @texier = Texier::Base.new
  end

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
  
  def test_only_allowed_classes_should_be_used
    @texier.allowed_classes = ['foo']
    assert_output '<p><em class="foo">hello</em></p>', '*hello .[foo]*'
    assert_output '<p><em>hello</em></p>', '*hello .[bar]*'
    assert_output '<p><em class="foo">hello</em></p>', '*hello .[foo bar]*'
  end

  def test_id
    assert_output '<p><em id="foo">hello</em></p>', '*hello .[#foo]*'
  end
  
  def test_only_allowed_ids_should_be_used
    @texier.allowed_classes = ['#foo']
    assert_output '<p><em id="foo">hello</em></p>', '*hello .[#foo]*'
    assert_output '<p><em>hello</em></p>', '*hello .[#bar]*'
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
  
  def test_onle_allowed_styles_should_be_used
    @texier.allowed_styles = ['font-size']
    assert_output(
      '<p><em style="font-size: 20px">hello</em></p>', 
      '*hello .{font-size: 20px}*'
    )
    assert_output '<p><em>hello</em></p>', '*hello .{color: red}*'
    assert_output(
      '<p><em style="font-size: 20px">hello</em></p>', 
      '*hello .{font-size: 20px; color: red}*'
    )
  end
  
  def test_when_style_name_is_valid_attribute_name_it_should_be_used_as_attribute
    assert_output(
      '<p><em onclick="hello()">hello</em></p>',
      '*hello .{onclick: hello()}*'
    )
  end
  
  def test_only_allowed_attributes_should_be_used
    @texier.allowed_tags = {'em' => ['onclick']}
	
    assert_output(
      '<p><em onclick="hello()">hello</em></p>', 
      '*hello .{onclick: hello()}*'
    )
    assert_output '<p><em>hello</em></p>', '*hello .{onmouseover: hello()}*'
  end

  def test_horizontal_align
    assert_output(
      '<p style="text-align: left">hello world</p>',
      ".<\nhello world"
    )
  end

  def test_horizontal_align_with_specified_align_class
    @texier.align_classes[:left] = 'foo'
    
    assert_output(
      '<p class="foo">hello world</p>',
      ".<\nhello world"
    )
  end
  
  def test_horizontal_align_should_be_used_only_if_text_align_style_is_allowed
    @texier.allowed_styles = nil
    assert_output '<p>hello</p>', ".<\nhello"
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

  def test_disallow_modifier
    @texier.allowed['modifier'] = false

    assert_output '<p><em>hello .[foo]</em></p>', '*hello .[foo]*'
  end
end
