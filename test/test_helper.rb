$KCODE = 'u'

require 'rubygems'
require 'test/unit'
require 'mocha'

$:.unshift("#{File.dirname(__FILE__)}/../lib")

require 'processor'

class Test::Unit::TestCase
  # Assert that Texier produces expected output from given input.
  def assert_output(expected, input)
    expected = unindent(expected)
    input = unindent(input)
    
    actual = (@processor || Texier::Processor.new).process(input)
    
    assert_block "<#{expected.inspect}> expected but was\n<#{actual.inspect}>." do
      expected == actual
    end
  end
  
  private
  
  def unindent(string)
    lines = string.split(/\n/)
    first_line = lines.shift || ''
    
    spaces = lines.inject(string.length) do |spaces, line|
      [spaces, line[/^ */].length].min
    end
    
    lines.inject(first_line) do |result, line|
      "#{result}\n#{line[spaces..-1]}"
    end
  end
end