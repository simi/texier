$KCODE = 'u'

require 'rubygems'
require 'test/unit'
require 'mocha'

$:.unshift("#{File.dirname(__FILE__)}/../lib")

require 'processor'

class Test::Unit::TestCase
  # Assert that Texier produces expected output from given input.
  def assert_output(expected, input)
    processor = Texier::Processor.new    
    assert_equal expected, processor.process(input)
  end
end