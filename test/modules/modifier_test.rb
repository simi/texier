require "#{File.dirname(__FILE__)}/../test_helper"

# Test case for Texier::Modules::Modifier class
class ModifierTest < Test::Unit::TestCase
  def test_modifier_should_be_optional
    assert_output '<p><em>foo</em></p>', '*foo*'
  end
  
  def test_title
    assert_output '<p><em title="foo">bar</em></p>', '*bar .(foo)*'
  end
end
