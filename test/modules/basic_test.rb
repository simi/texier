require "#{File.dirname(__FILE__)}/../test_helper"

# Test case for Texier::Modules::Basic class
class BasicTest < Test::Unit::TestCase
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
  
  def test_paragraph_with_newlines
    assert_output "<p>one\ntwo\nthree</p>", "one\ntwo\nthree"
  end
  
  def test_paragraph_with_newlines_starting_with_newline
    assert_output "<p>one\ntwo\nthree</p>", "\none\ntwo\nthree"
  end
  
  def test_one_paragraph_with_some_newlines_before_or_after_it
    assert_output '<p>hello world</p>', "\n\n\nhello world"
    assert_output '<p>hello world</p>', "hello world\n\n\n"
  end
  
  def test_paragraph_should_strip_whitespace_from_begining_of_its_content
    assert_output '<p>first</p><p>second</p>', "first\n\n   second"
  end
  
  def test_paragraph_with_modifier
    assert_output(
      '<p class="foo">hello world</p>',
      ".[foo]\nhello world"
    )
  end
  
  def test_paragraph_should_not_consume_block_element_right_ater_it
    assert_output(
      '<p>paragraph</p><blockquote><p>blockquote</p></blockquote>',
      "paragraph\n> blockquote"
    )
  end
  
  def test_newlines_should_be_standardized
    assert_output(
      "<p>windows/dos\nmac\nunix\nhello world</p>",
      "windows/dos\r\nmac\runix\nhello world"
    )
  end
  
  def test_tabs_should_be_converted_to_spaces
    assert_output "<p>hello\n    world</p>", "hello\n\tworld"
    assert_output "<p>first\n    second\n3:  third</p>", "first\n\tsecond\n3:\tthird"
  end
end