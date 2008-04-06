require "#{File.dirname(__FILE__)}/../test_helper"

class Texier::Modules::ImageTest < Test::Unit::TestCase
  def test_image
    assert_output '<p><img src="/images/hello.jpg" /></p>', '[* hello.jpg *]'
  end
  
  def test_image_should_be_aligned_using_left_and_right_class_options_if_they_are_set
    @processor = Texier::Processor.new
    @processor.image_module.left_class = 'left'
    @processor.image_module.right_class = 'right'
    
    assert_output(
      '<p><img class="left" src="/images/hello.jpg" /></p>',
      '[* hello.jpg <]'
    )
    
    assert_output(
      '<p><img class="right" src="/images/hello.jpg" /></p>',
      '[* hello.jpg >]'
    )
  end
  
  def test_image_should_be_aligned_using_global_align_class_if_it_is_set
    @processor = Texier::Processor.new
    @processor.align_classes[:left] = 'left'
    @processor.align_classes[:right] = 'right'
    
    assert_output(
      '<p><img class="left" src="/images/hello.jpg" /></p>',
      '[* hello.jpg <]'
    )
    
    assert_output(
      '<p><img class="right" src="/images/hello.jpg" /></p>',
      '[* hello.jpg >]'
    )
  end
  
  def test_image_should_be_aligned_using_inline_style_if_align_class_is_nil
    assert_output(
      '<p><img src="/images/hello.jpg" style="float: left" /></p>',
      '[* hello.jpg <]'
    )
    
    assert_output(
      '<p><img src="/images/hello.jpg" style="float: right" /></p>',
      '[* hello.jpg >]'
    )
  end
end
