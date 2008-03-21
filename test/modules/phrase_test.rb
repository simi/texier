require "#{File.dirname(__FILE__)}/../test_helper"

# Test case for Texier::Modules::Phrase class
class PhraseTest < Test::Unit::TestCase
  def test_emphasis
    assert_output '<p><em>hello world</em></p>', '*hello world*'
    assert_output '<p><em>hello world</em></p>', '//hello world//'
  end

  def test_emphasis_and_plain_text
    assert_output '<p>hello <em>world</em> again</p>', 'hello *world* again'
  end

  def test_strong
    assert_output '<p><strong>hello world</strong></p>', '**hello world**'
  end

  def test_strong_emphasis
    assert_output(
      '<p><strong><em>hello</em></strong></p>',
      '***hello***'
    )
  end

  def test_quote
    assert_output '<p><q>hello world</q></p>', '>>hello world<<'
  end
  
  def test_code
    assert_output '<p><code>def test_code</code></p>', '`def test_code`'
  end
  
end