require "#{File.dirname(__FILE__)}/../test_helper"

# Test case for class Texier::Modules::Figure
class Texier::Modules::FigureTest < Test::Unit::TestCase
  def test_figure
    assert_equal_output(
      '<div class="figure"><img src="/images/hello.jpg" /><p>hello world</p></div>',
      '[* hello.jpg *] *** hello world'
    )
  end
  
  def test_figure_with_inline_elements
    assert_equal_output(
      '<div class="figure"><img src="/images/hello.jpg" /><p>hello <em>world</em></p></div>',
      '[* hello.jpg *] *** hello *world*'
    )
  end
  
  def test_figure_with_modifier
    assert_equal_output(
      '<div class="figure foo"><img src="/images/hello.jpg" /><p>hello world</p></div>',
      '[* hello.jpg *] *** hello world .[foo]'
    )
  end
  
  def test_figure_class_should_be_configurable
    @texier = Texier::Base.new
    @texier.figure_module.class_name = 'foo'
    
    assert_equal_output(
      '<div class="foo"><img src="/images/hello.jpg" /><p>hello world</p></div>',
      '[* hello.jpg *] *** hello world'
    )
  end
  
  def test_figure_aligned_with_inline_style
    assert_equal_output(
      '<div class="figure" style="float: right">' \
      '<img src="/images/hello.jpg" /><p>hello world</p></div>',
      '[* hello.jpg >] *** hello world'
    )
  end
  
  def test_figure_aligned_with_class
    @texier = Texier::Base.new
    @texier.image_module.right_class = 'right'
    
    assert_equal_output(
      '<div class="figure right"><img src="/images/hello.jpg" /><p>hello world</p></div>',
      '[* hello.jpg >] *** hello world'
    )
  end
end
