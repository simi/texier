require "#{File.dirname(__FILE__)}/../test_helper"

# Test case for Texier::Modules::Phrase class
class Texier::Modules::PhraseTest < Test::Unit::TestCase
  def setup
    @texier = Texier::Base.new
    @texier.allowed['typography'] = false # This just simplifies testing.
  end
  
  def test_em
    assert_equal_output '<p><em>hello world</em></p>', '*hello world*'
    assert_equal_output '<p><em>hello world</em></p>', '//hello world//'
  end

  def test_em_and_plain_text
    assert_equal_output '<p>hello <em>world</em> again</p>', 'hello *world* again'
  end
  
  def test_em_with_modifier
    assert_equal_output(
      '<p><em class="foo">hello world</em></p>',
      '*hello world .[foo]*'
    )
  end

  def test_strong
    assert_equal_output '<p><strong>hello world</strong></p>', '**hello world**'
  end

  def test_strong_em
    assert_equal_output(
      '<p><strong><em>hello</em></strong></p>',
      '***hello***'
    )
  end

  def test_quote
    assert_equal_output '<p><q>hello world</q></p>', '>>hello world<<'
  end
  
  def test_quote_with_cite
    assert_equal_output(
      '<p><q cite="http://metatribe.org">hello world</q></p>',
      '>>hello world<<:http://metatribe.org'
    )
  end
  
  def test_code
    assert_equal_output '<p><code>def test_code</code></p>', '`def test_code`'
  end
  
  def test_content_of_code_should_be_escaped
    assert_equal_output '<p><code>if x &lt; y</code></p>', '`if x < y`'
  end
  
  def test_ins
    @texier.allowed['phrase/ins'] = true
    assert_equal_output '<p><ins>hello world</ins></p>', '++hello world++'
  end
  
  def test_ins_should_be_disabled_by_default
    assert_equal_output '<p>++hello world++</p>', '++hello world++'
  end

  def test_del
    @texier.allowed['phrase/del'] = true
    assert_equal_output '<p><del>hello world</del></p>', '--hello world--'
  end

  def test_del_should_be_disabled_by_default
    assert_equal_output '<p>--hello world--</p>', '--hello world--'
  end
  
  def test_sup
    @texier.allowed['phrase/sup'] = true
    assert_equal_output '<p>x<sup>2</sup></p>', 'x^^2^^'

    assert_equal_output '<p>x<sup>2</sup></p>', 'x^2'
    assert_equal_output '<p>x ^2</p>', 'x ^2'
  end

  def test_sup_should_be_disabled_by_default
    assert_equal_output '<p>x^^2^^</p>', 'x^^2^^'
  end

  def test_sub
    @texier.allowed['phrase/sub'] = true
    assert_equal_output '<p>x<sub>2</sub></p>', 'x__2__'
    
    assert_equal_output '<p>x<sub>2</sub></p>', 'x_2'
  end

  def test_sub_should_be_disabled_by_default
    assert_equal_output '<p>x__2__</p>', 'x__2__'
  end
  
  def test_alternative_sup_and_sub_with_negative_number
    assert_equal_output "<p>x<sup>\xE2\x88\x922</sup></p>", 'x^-2'
    assert_equal_output "<p>x<sub>\xE2\x88\x922</sub></p>", 'x_-2'
  end
  
  def test_cite
    @texier.allowed['phrase/cite'] = true
    assert_equal_output '<p><cite>hello world</cite></p>', '~~hello world~~'
  end

  def test_cite_should_be_disabled_by_default
    assert_equal_output '<p>~~hello world~~</p>', '~~hello world~~'
  end
  
  def test_acronym
    assert_equal_output(
      '<p><acronym title="don\'t repeat yourself">DRY</acronym></p>',
      'DRY((don\'t repeat yourself))'
    )
    
    assert_equal_output(
      '<p><acronym title="and others">et. al</acronym></p>',
      '"et. al"((and others))'
    )
  end
  
  def test_acronym_should_be_recognized_only_if_it_has_at_least_two_letters
    assert_equal_output '<p>F((Foo))</p>', 'F((Foo))'
  end
  
  def test_phrase_with_link
    assert_equal_output(
      '<p><a href="http://metatribe.org"><em>hello world</em></a></p>',
      '*hello world*:http://metatribe.org'
    )
    
    assert_equal_output(
      '<p><a href="http://metatribe.org/weird-stuff?"><em>hello world</em></a></p>',
      '*hello world*:[http://metatribe.org/weird-stuff?]'
    )
  end
  
  def test_quick_link
    assert_equal_output(
      '<p><a href="http://metatribe.org">hello</a></p>',
      'hello:http://metatribe.org'
    )
  end
  
  def test_span_with_link
    assert_equal_output(
      '<p><a href="http://metatribe.org">hello</a></p>',
      '"hello":http://metatribe.org'
    )
    
    assert_equal_output(
      '<p><a href="http://metatribe.org">hello</a></p>',
      '~hello~:http://metatribe.org'
    )
  end
  
  def test_span_with_modifier
    assert_equal_output(
      '<p><span class="foo">hello</span></p>',
      '"hello .[foo]"'
    )
    
    assert_equal_output(
      '<p><span class="foo">hello</span></p>',
      '~hello .[foo]~'
    )
  end
  
  def test_span_with_link_and_modifier
    assert_equal_output(
      '<p><a class="foo" href="http://metatribe.org">hello</a></p>',
      '"hello .[foo]":http://metatribe.org'
    )
    
    assert_equal_output(
      '<p><a class="foo" href="http://metatribe.org">hello</a></p>',
      '~hello .[foo]~:http://metatribe.org'
    )
  end
  
  def test_span_without_link_or_modifier_should_be_ignored
    assert_equal_output '<p>"hello"</p>', '"hello"'
    assert_equal_output '<p>~hello~</p>', '~hello~'
  end
  
  def test_notexy
    assert_equal_output '<p>*hello*</p>', "''*hello*''"
    assert_equal_output '<p>&lt;em&gt;hello&lt;/em&gt;</p>', "''<em>hello</em>''"
  end
  
  def test_links_allowed_set_to_false
    @texier.phrase_module.links_allowed = false
    
    # TODO: Not sure if this is desired behavior. Check how Texy! does it.
    
    assert_equal_output(
      '<p><em>hello</em>:<a href="http://metatribe.org">http://metatribe.org</a></p>', 
      '*hello*:http://metatribe.org'
    )
  end
  
  def test_when_links_are_disabled_span_with_link_and_no_modifier_should_be_ignored
    @texier.phrase_module.links_allowed = false
    
    # TODO: Not sure if this is desired behavior. Check how Texy! does it.

    assert_equal_output(
      '<p>"hello":<a href="http://metatribe.org">http://metatribe.org</a></p>',
      '"hello":http://metatribe.org'
    )
  end
end