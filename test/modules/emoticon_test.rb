require "#{File.dirname(__FILE__)}/../test_helper"

# Test case for class Texier::Modules::Emoticon
class EmoticonTest < Test::Unit::TestCase
  def test_emoticons_should_be_disabled_by_default
    assert_output '<p>:-)</p>', ':-)'
  end
  
  def test_emoticons
    @processor = Texier::Processor.new
    @processor.allowed['emoticon'] = true
    
    assert_output '<p><img alt=":-)" src="smile.gif" /></p>', ':-)' 
    assert_output '<p><img alt=";-)" src="wink.gif" /></p>', ';-)' 
    assert_output '<p><img alt=":-(" src="sad.gif" /></p>', ':-(' 
    # etc...
  end
  
  def test_repeated_mouth_should_be_accepted
    @processor = Texier::Processor.new
    @processor.allowed['emoticon'] = true

    assert_output '<p><img alt=":-)" src="smile.gif" /></p>', ':-))))'
  end
  
  def test_class_name
    @processor = Texier::Processor.new
    @processor.allowed['emoticon'] = true
    @processor.emoticon_module.class_name = 'smilie'
    
    assert_output(
      '<p><img alt=":-)" class="smilie" src="smile.gif" /></p>', ':-)'
    )
  end
end
