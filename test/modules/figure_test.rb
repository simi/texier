require "#{File.dirname(__FILE__)}/../test_helper"

# Test case for class Texier::Modules::Figure
class Texier::Modules::FigureTest < Test::Unit::TestCase
  def test_figure
    assert_output(
      '<div class="figure"><img src="/images/hello.jpg" /><p>hello world</p></div>',
      '[* hello.jpg *] *** hello world'
    )
  end
end
