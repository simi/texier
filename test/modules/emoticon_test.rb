require "#{File.dirname(__FILE__)}/../test_helper"

# Test case for class Texier::Modules::Emoticon
class Texier::Modules::EmoticonTest < Test::Unit::TestCase
  def test_emoticons_should_be_disabled_by_default
    assert_equal_output '<p>:-)</p>', ':-)'
  end
  
  def test_emoticons
    @texier = Texier::Base.new
    @texier.allowed['emoticon'] = true
    
    assert_equal_output '<p><img alt=":-)" src="smile.gif" /></p>', ':-)' 
    assert_equal_output '<p><img alt=";-)" src="wink.gif" /></p>', ';-)' 
    assert_equal_output '<p><img alt=":-(" src="sad.gif" /></p>', ':-(' 
    # etc...
  end
  
  def test_repeated_mouth_should_be_accepted
    @texier = Texier::Base.new
    @texier.allowed['emoticon'] = true

    assert_equal_output '<p><img alt=":-)" src="smile.gif" /></p>', ':-))))'
  end
  
  def test_class_name
    @texier = Texier::Base.new
    @texier.allowed['emoticon'] = true
    @texier.emoticon_module.class_name = 'smilie'
    
    assert_equal_output(
      '<p><img alt=":-)" class="smilie" src="smile.gif" /></p>', ':-)'
    )
  end
end
