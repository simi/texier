require "#{File.dirname(__FILE__)}/test_helper"

class Texier::UtilitiesTest < Test::Unit::TestCase
  def test_prepend_root_should_return_url_unchanged_if_root_is_nil_or_empty
    assert_equal 'url', Texier::Utilities.prepend_root('url', nil)
    assert_equal 'url', Texier::Utilities.prepend_root('url', '')
  end
  
  def test_prepend_root_should_correctly_handle_slashes
    assert_equal 'root/url', Texier::Utilities.prepend_root('url', 'root')
    assert_equal 'root/url', Texier::Utilities.prepend_root('url', 'root/')
    assert_equal 'root/url', Texier::Utilities.prepend_root('/url', 'root')
    assert_equal 'root/url', Texier::Utilities.prepend_root('/url', 'root/')
  end
end
