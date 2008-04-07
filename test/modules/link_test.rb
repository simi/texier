require "#{File.dirname(__FILE__)}/../test_helper"

class Texier::Modules::LinkTest < Test::Unit::TestCase
  def test_direct_url
    assert_output(
      '<p><a href="http://metatribe.org">http://metatribe.org</a></p>',
      'http://metatribe.org'
    )    
  end
  
  def test_direct_url_should_be_prefixed_with_protocol_if_it_is_absolute
    assert_output(
      '<p><a href="http://www.metatribe.org">www.metatribe.org</a></p>',
      'www.metatribe.org'
    )    
  end
  
  def test_direct_email
    assert_output(
      '<p><a href="mailto:me@world.com">me@world.com</a></p>',
      'me@world.com'
    )
  end
  
  def test_url_reference
    assert_output(
      '<p><a href="http://metatribe.org">check this out</a></p>',
      "\"check this out\":[metatribe]\n\n[metatribe]: http://metatribe.org"
    )
  end
  
  def test_url_reference_should_accept_arbitrary_string
    assert_output(
      '<p><a href="bar">check this out</a></p>',
      "\"check this out\":[foo]\n\n[foo]: bar"
    )
  end
  
  def test_url_reference_should_be_prefixed_with_protocol_if_it_is_absolute
    assert_output(
      '<p><a href="http://www.metatribe.org">check this out</a></p>',
      "\"check this out\":[metatribe]\n\n[metatribe]: www.metatribe.org"
    )
  end
  
  def test_link_reference
    assert_output(
      '<p><a href="http://metatribe.org">check this out</a></p>',
      "[metatribe]\n\n[metatribe]: http://metatribe.org check this out"
    )
  end
  
  def test_link_reference_with_modifier
    assert_output(
      '<p><a class="foo" href="http://metatribe.org">check this out</a></p>',
      "[metatribe]\n\n[metatribe]: http://metatribe.org check this out .[foo]"
    )
  end
  
  def test_many_references
    assert_output(
      '<p><a href="foo">click me!</a> <a href="bar">me too!</a></p>',
      "[foo] [bar]\n\n[foo]: foo click me!\n[bar]: bar me too!"
    )
  end
end
