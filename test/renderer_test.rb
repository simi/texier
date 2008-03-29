require "#{File.dirname(__FILE__)}/test_helper"

# Test case for Texier::Renderer class
class RendererTest < Test::Unit::TestCase
  def setup
    @renderer = Texier::Renderer.new
  end

  def test_empty_element_should_be_rendered_as_empty_string
    assert_equal '', @renderer.render(nil)
    assert_equal '', @renderer.render('')
    assert_equal '', @renderer.render([])
  end

  def test_string_should_be_rendered_as_itself
    assert_equal 'hello world', @renderer.render('hello world')
  end

  def test_array_should_be_rendered_as_concatenation_of_renderings_of_its_items
    assert_equal 'foobar', @renderer.render(['foo', 'bar'])
  end

  def test_element_should_be_rendered_with_tags
    element = Texier::Element.new(:foo, 'hello world')

    assert_equal '<foo>hello world</foo>', @renderer.render(element)
  end

  def test_element_with_simple_attribute
    element = Texier::Element.new(:foo, 'hello', :class => 'bar')

    assert_equal '<foo class="bar">hello</foo>', @renderer.render(element)
  end

  def test_attribute_values_should_be_sanitized
    element = Texier::Element.new('em', 'name' => '"hello <world>"')
    assert_equal(
      '<em name="&quot;hello &lt;world&gt;&quot;"></em>',
      @renderer.render(element)
    )
  end

  def test_attribute_with_empty_nil_or_false_value_should_be_ignored
    element = Texier::Element.new('em', 'name' => nil)
    assert_equal('<em></em>', @renderer.render(element))

    element = Texier::Element.new('em', 'name' => false)
    assert_equal('<em></em>', @renderer.render(element))

    element = Texier::Element.new('em', 'name' => '')
    assert_equal('<em></em>', @renderer.render(element))
  end

  def test_array_attribute
    element = Texier::Element.new('em', 'class' => ['foo', 'bar'])

    assert_equal '<em class="foo bar"></em>', @renderer.render(element)
  end

  def test_hash_attribute
    element = Texier::Element.new('em', 'style' => {
        'font-family' => 'sans-serif',
        'color' => 'red'
      })

    assert_equal(
      '<em style="font-family: sans-serif; color: red"></em>',
      @renderer.render(element)
    )
  end

  def test_empty_element
    element = Texier::Element.new('br')
    assert_equal '<br />', @renderer.render(element)
  end

  def test_render_text
    element = Texier::Element.new('em', 'hello', 'class' => 'bar')
    assert_equal 'hello', @renderer.render_text(element)

    element = Texier::Element.new('strong', Texier::Element.new('em', 'hello'))
    assert_equal 'hello', @renderer.render_text(element)
  end
end
