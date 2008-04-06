require "#{File.dirname(__FILE__)}/test_helper"
require "processor"

# Test case for Texier::Processor class
class Texier::ProcessorTest < Test::Unit::TestCase
  def setup
    @processor = Texier::Processor.new
  end
  
  def test_dom_of_new_processor_should_be_nil
    assert_nil @processor.dom
  end
  
  def test_access_to_modules
    assert_nothing_raised do
      mod = @processor.basic_module
      assert_kind_of Texier::Module, mod
    end
  end
  
  def test_everything_should_be_allowed_by_default
    assert @processor.allowed['phrase/em']
  end
  
  def test_disallow
    assert_equal '<p><em>hello</em></p>', @processor.process('*hello*')
    
    @processor.allowed['phrase/em'] = false
    assert_equal '<p>*hello*</p>', @processor.process('*hello*')
  end
  
  def test_tag_allowed
    @processor.allowed_tags = :all
    assert @processor.tag_allowed?('strong')
	
    @processor.allowed_tags = {'strong' => :all}
    assert @processor.tag_allowed?('strong')
    assert !@processor.tag_allowed?('em')
	
    @processor.allowed_tags = {'strong' => ['title']}
    assert @processor.tag_allowed?('strong')

    @processor.allowed_tags = {'strong' => nil}
    assert !@processor.tag_allowed?('strong')
	
    @processor.allowed_tags = nil
    assert !@processor.tag_allowed?('strong')
  end
  
  def test_attribute_allowed
    @processor.allowed_tags = :all
    assert @processor.attribute_allowed?('strong', 'onclick')
	
    @processor.allowed_tags = {'strong' => :all}
    assert @processor.attribute_allowed?('strong', 'onclick')
	
    @processor.allowed_tags = {'strong' => ['onclick']}
    assert @processor.attribute_allowed?('strong', 'onclick')
    assert !@processor.attribute_allowed?('strong', 'onmouseover')
	
    @processor.allowed_tags = nil
    assert !@processor.attribute_allowed?('strong', 'onclick')
	
    @processor.allowed_tags = {'strong' => nil}
    assert !@processor.attribute_allowed?('strong', 'onclick')
	
    @processor.allowed_tags = {'strong' => []}
    assert !@processor.attribute_allowed?('strong', 'onclick')
  end
  
  def test_class_allowed
    @processor.allowed_classes = :all
    assert @processor.class_allowed?('foo')
	
    @processor.allowed_classes = ['foo']
    assert @processor.class_allowed?('foo')
    assert !@processor.class_allowed?('bar')

    @processor.allowed_classes = []
    assert !@processor.class_allowed?('foo')
	
    @processor.allowed_classes = nil
    assert !@processor.class_allowed?('foo')
  end
  
  def test_style_allowed
    @processor.allowed_styles = :all
    assert @processor.style_allowed?('font-size')
	
    @processor.allowed_styles = ['font-size']
    assert @processor.style_allowed?('font-size')
    assert !@processor.style_allowed?('color')

    @processor.allowed_styles = []
    assert !@processor.style_allowed?('font-size')
	
    @processor.allowed_styles = nil
    assert !@processor.style_allowed?('font-size')
  end
end
