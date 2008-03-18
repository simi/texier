require "#{File.dirname(__FILE__)}/../test_helper"
require 'processor'

# Test case for Texier::Modules::Basic class
class BasicTest < Test::Unit::TestCase
  def test_parser_should_be_properly_initialized
    processor = stub('processor')
    
    basic = Texier::Modules::Basic.new(processor)
    parser = Texier::Parser.new
    
    basic.initialize_parser(parser)   
    
    assert parser.has_rule?(:document)
  end
  
  def test_empty_input_should_produce_empty_dom
    processor = Texier::Processor.new
    processor.process('')
    
    assert_equal [], processor.dom
  end

  def test_empty_input_should_produce_empty_output
    assert_equal '', Texier.process('')
  end
  
  def test_single_paragraph
    assert_equal '<p>hello world</p>', Texier.process('hello world')
  end
  
  def test_two_paragraphs
    assert_equal(
      '<p>hello world</p><p>hello another paragraph</p>',
      Texier::process("hello world\n\nhello another paragraph")
    )
  end
end
