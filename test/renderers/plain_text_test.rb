require "#{File.dirname(__FILE__)}/../test_helper"

# Test case for Texier::Renderers::PlainText class
class Texier::Renderers::PlainTextTest < Test::Unit::TestCase
  def setup
    @renderer = Texier::Renderers::PlainText.new
  end

  def test_render
    element = Texier::Element.new('em', 'hello', 'class' => 'bar')
    assert_equal 'hello', @renderer.render(element)

    element = Texier::Element.new('strong', Texier::Element.new('em', 'hello'))
    assert_equal 'hello', @renderer.render(element)
  end
end
