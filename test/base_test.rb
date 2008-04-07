require "#{File.dirname(__FILE__)}/test_helper"

# Test case for Texier::Base class
class Texier::BaseTest < Test::Unit::TestCase
  def setup
    @texier = Texier::Base.new
  end
  
  def test_dom_of_new_processor_should_be_nil
    assert_nil @texier.dom
  end
  
  def test_access_to_modules
    assert_nothing_raised do
      mod = @texier.core_module
      assert_kind_of Texier::Modules::Base, mod
    end
  end
  
  def test_everything_should_be_allowed_by_default
    assert @texier.allowed['phrase/em']
  end
  
  def test_disallow
    assert_equal '<p><em>hello</em></p>', @texier.process('*hello*')
    
    @texier.allowed['phrase/em'] = false
    assert_equal '<p>*hello*</p>', @texier.process('*hello*')
  end
  
  def test_tag_allowed
    @texier.allowed_tags = :all
    assert @texier.tag_allowed?('strong')
	
    @texier.allowed_tags = {'strong' => :all}
    assert @texier.tag_allowed?('strong')
    assert !@texier.tag_allowed?('em')
	
    @texier.allowed_tags = {'strong' => ['title']}
    assert @texier.tag_allowed?('strong')

    @texier.allowed_tags = {'strong' => nil}
    assert !@texier.tag_allowed?('strong')
	
    @texier.allowed_tags = nil
    assert !@texier.tag_allowed?('strong')
  end
  
  def test_attribute_allowed
    @texier.allowed_tags = :all
    assert @texier.attribute_allowed?('strong', 'onclick')
	
    @texier.allowed_tags = {'strong' => :all}
    assert @texier.attribute_allowed?('strong', 'onclick')
	
    @texier.allowed_tags = {'strong' => ['onclick']}
    assert @texier.attribute_allowed?('strong', 'onclick')
    assert !@texier.attribute_allowed?('strong', 'onmouseover')
	
    @texier.allowed_tags = nil
    assert !@texier.attribute_allowed?('strong', 'onclick')
	
    @texier.allowed_tags = {'strong' => nil}
    assert !@texier.attribute_allowed?('strong', 'onclick')
	
    @texier.allowed_tags = {'strong' => []}
    assert !@texier.attribute_allowed?('strong', 'onclick')
  end
  
  def test_class_allowed
    @texier.allowed_classes = :all
    assert @texier.class_allowed?('foo')
	
    @texier.allowed_classes = ['foo']
    assert @texier.class_allowed?('foo')
    assert !@texier.class_allowed?('bar')

    @texier.allowed_classes = []
    assert !@texier.class_allowed?('foo')
	
    @texier.allowed_classes = nil
    assert !@texier.class_allowed?('foo')
  end
  
  def test_style_allowed
    @texier.allowed_styles = :all
    assert @texier.style_allowed?('font-size')
	
    @texier.allowed_styles = ['font-size']
    assert @texier.style_allowed?('font-size')
    assert !@texier.style_allowed?('color')

    @texier.allowed_styles = []
    assert !@texier.style_allowed?('font-size')
	
    @texier.allowed_styles = nil
    assert !@texier.style_allowed?('font-size')
  end
end
