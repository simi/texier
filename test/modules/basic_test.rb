require "#{File.dirname(__FILE__)}/../test_helper"

# Test case for Texier::Modules::Basic class
class BasicTest < Test::Unit::TestCase
  def test_parser_should_be_properly_initialized
    basic = Texier::Modules::Basic.new
    parser = Texier::Parser.new
    
    basic.initialize_parser(parser)   
    
    assert parser.has_expression?(:document)
  end
  
  def test_empty_input_should_produce_empty_dom
    processor = Texier::Processor.new
    processor.process('')
    
    assert_equal [], processor.dom
  end

  def test_empty_input_should_produce_empty_output
    assert_output '', ''
  end
  
  def test_single_paragraph
    assert_output '<p>hello world</p>', 'hello world'
  end
  
  def test_two_paragraphs
    assert_output(
      '<p>hello world</p><p>hello another paragraph</p>',
      "hello world\n\nhello another paragraph"
    )
  end
  
  def test_one_paragraph_with_some_newlines_before_or_after_it
    assert_output '<p>hello world</p>', "\n\n\nhello world"
    assert_output '<p>hello world</p>', "hello world\n\n\n"
  end
end
