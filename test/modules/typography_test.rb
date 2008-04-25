require "#{File.dirname(__FILE__)}/../test_helper"

# Test case for Texier::Modules::Typography class
class Texier::Modules::TypographyTest < Test::Unit::TestCase
  def test_locale
    @texier = Texier::Base.new
    
    @texier.typography_module.locale = 'en'
    assert_output "<p>\xe2\x80\x9cfoo\xe2\x80\x9d</p>", '"foo"'
    
    @texier.typography_module.locale = 'fr'
    assert_output "<p>\xc2\xabfoo\xc2\xbb</p>", '"foo"'
    
    @texier = nil
  end
  
  def test_double_quotes
    assert_output "<p>\xe2\x80\x9chello world\xe2\x80\x9d</p>", '"hello world"'
  end
  
  def test_single_quotes
    assert_output(
      "<p>\xe2\x80\x98hello world\xe2\x80\x99</p>", '\'hello world\''
    )
  end
  
  def test_inline_elements_inside_quotes
    assert_output(
      "<p>\xe2\x80\x9chello <em>world</em>\xe2\x80\x9d</p>", 
      '"hello *world*"'
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
  
  def test_date
    assert_output "<p>1.\xc2\xa01.\xc2\xa01970</p>", '1. 1. 1970'
    assert_output "<p>1.\xc2\xa01.</p>", '1. 1.'
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
  
  def test_dimension_sign
    assert_output "<p>1024\xc3\x97768</p>", '1024x768'
    assert_output "<p>1024\xc3\x97768</p>", '1024 x 768'
    
    assert_output "<p>150\xc3\x97</p>", '150x'
  end
  
  def test_trademark
    assert_output "<p>RadAway\xe2\x84\xa2</p>", 'RadAway (TM)'
    assert_output "<p>RadAway\xe2\x84\xa2</p>", 'RadAway (tm)'
    assert_output "<p>RadAway\xe2\x84\xa2</p>", 'RadAway(tm)'
  end
  
  def test_registered
    assert_output "<p>RadAway\xc2\xae</p>", 'RadAway (R)'
    assert_output "<p>RadAway\xc2\xae</p>", 'RadAway (r)'
    assert_output "<p>RadAway\xc2\xae</p>", 'RadAway(r)'
  end
  
  def test_copyright
    assert_output "<p>\xc2\xa9 2008</p>", '(c) 2008'
    assert_output "<p>\xc2\xa9 2008</p>", '(C) 2008'
  end
  
  def test_euro_sign
    assert_output "<p>\xe2\x82\xac1000</p>", '(eur)1000'
    assert_output "<p>\xe2\x82\xac1000</p>", '(EUR)1000'
  end
  
  def test_phone_number
    assert_output "<p>1\xc2\xa0234\xc2\xa0567</p>", '1 234 567'
  end
  
end
