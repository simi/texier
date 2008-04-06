require "#{File.dirname(__FILE__)}/test_helper"

module Texier::Modules
  class Test < Texier::Module
    options :foo => 'red', :bar => 'green'
  end
end

# Test case for Texier::Module class
class Texier::ModuleTest < Test::Unit::TestCase
  def test_options_should_have_default_value
    test_mod = Texier::Modules::Test.new

    assert_equal 'red', test_mod.foo
    assert_equal 'green', test_mod.bar
  end
end
