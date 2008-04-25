require "#{File.dirname(__FILE__)}/../test_helper"

# Test case for Texier::Modules::Typography class
class Texier::Modules::TypographyTest < Test::Unit::TestCase
  def test_locale
    @texier = Texier::Base.new
    
    @texier.typography_module.locale = 'en'
    assert_output "<p>\xe2\x80\x9cfoo\xe2\x80\x9d</p>", '"foo"'
    
    @texier.typography_module.locale = 'fr'
    assert_output "<p>\xc2\xabfoo\xc2\xbb</p>", '"foo"'
  end
  
  def test_double_quotes
    assert_output "<p>\xe2\x80\x9chello world\xe2\x80\x9d</p>", '"hello world"'
  end
  
  def test_single_quotes
    assert_output(
      "<p>\xe2\x80\x98hello world\xe2\x80\x99</p>", '\'hello world\''
    )
  end
  
  def test_ellipsis
    assert_output "<p>foo\xe2\x80\xa6</p>", 'foo...'
  end
  
  def test_en_dash
    assert_output "<p>123\xe2\x80\x93456</p>", '123-456'
    # TODO: assert_output "<p>hello\xe2\x80\x93world</p>", 'hello--world'
    assert_output "<p>123,\xe2\x80\x93</p>", '123,-'
  end
  
  def test_em_dash
    assert_output "<p>hello\xc2\xa0\xe2\x80\x94 world</p>", 'hello --- world'
  end
  
  def test_left_right_arrow
    assert_output "<p>hello \xe2\x86\x94 world</p>", 'hello <-> world'
    assert_output "<p>hello \xe2\x86\x94 world</p>", 'hello <--> world'
  end
  
  def test_right_arrow
    assert_output "<p>hello \xe2\x86\x92 world</p>", 'hello -> world'
    assert_output "<p>hello \xe2\x86\x92 world</p>", 'hello --> world'
    
    assert_output "<p>hello \xe2\x87\x92 world</p>", 'hello => world'
    assert_output "<p>hello \xe2\x87\x92 world</p>", 'hello ==> world'
  end
    
  def test_left_arrow
    assert_output "<p>hello \xe2\x86\x90 world</p>", 'hello <- world'
    assert_output "<p>hello \xe2\x86\x90 world</p>", 'hello <-- world'
  end
end
