$KCODE = 'u'

require 'rubygems'
require 'test/unit'
require 'mocha'

$:.unshift("#{File.dirname(__FILE__)}/../lib")

require 'processor'

class String
  def unindent
    lines = split(/\n/)
    first_line = lines.shift || ''
    
    spaces = lines.inject(length) do |spaces, line|
      line =~ /^[\t ]*$/ ? spaces : [spaces, line[/^ */].length].min
    end
    
    lines.inject(first_line) do |result, line|
      "#{result}\n#{line[spaces..-1]}"
    end
  end
end

class Test::Unit::TestCase
  include Texier::Parser::Generators
  
  # Assert that Texier produces expected output from given input.
  def assert_output(expected, input)
    actual = (@processor || Texier::Processor.new).process(input)
    
    message = ''
    message << "<#{input.inspect}> should result in\n"
    message << "<#{expected.inspect}> but was\n"
    message << "<#{actual.inspect}> instead."
    
    assert_block message do
      expected == actual
    end
  end
end