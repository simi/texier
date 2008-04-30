require "#{File.dirname(__FILE__)}/../test_helper"

class Texier::Modules::ImageTest < Test::Unit::TestCase
  def test_image
    assert_equal_output '<p><img src="/images/hello.jpg" /></p>', '[* hello.jpg *]'
  end
  
  def test_image_should_be_aligned_using_left_and_right_class_options_if_they_are_set
    @texier = Texier::Base.new
    @texier.image_module.left_class = 'left'
    @texier.image_module.right_class = 'right'
    
    assert_equal_output(
      '<p><img class="left" src="/images/hello.jpg" /></p>',
      '[* hello.jpg <]'
    )
    
    assert_equal_output(
      '<p><img class="right" src="/images/hello.jpg" /></p>',
      '[* hello.jpg >]'
    )
  end
  
  def test_image_should_be_aligned_using_global_align_class_if_it_is_set
    @texier = Texier::Base.new
    @texier.align_classes[:left] = 'left'
    @texier.align_classes[:right] = 'right'
    
    assert_equal_output(
      '<p><img class="left" src="/images/hello.jpg" /></p>',
      '[* hello.jpg <]'
    )
    
    assert_equal_output(
      '<p><img class="right" src="/images/hello.jpg" /></p>',
      '[* hello.jpg >]'
    )
  end
  
  def test_image_should_be_aligned_using_inline_style_if_align_class_is_nil
    assert_equal_output(
      '<p><img src="/images/hello.jpg" style="float: left" /></p>',
      '[* hello.jpg <]'
    )
    
    assert_equal_output(
      '<p><img src="/images/hello.jpg" style="float: right" /></p>',
      '[* hello.jpg >]'
    )
  end
  
  def test_image_with_modifier
    assert_equal_output(
      '<p><img class="foo" src="/images/hello.jpg" /></p>',
      '[* hello.jpg .[foo] *]'
    )
  end
  
  def test_title_modifier_should_be_applied_as_alt
    assert_equal_output(
      '<p><img alt="hello world" src="/images/hello.jpg" /></p>',
      '[* hello.jpg .(hello world) *]'
    )
  end
  
  def test_if_alt_is_not_set_default_alt_should_be_used
    @texier = Texier::Base.new
    @texier.image_module.default_alt = 'hello world'
    
    assert_equal_output(
      '<p><img alt="hello world" src="/images/hello.jpg" /></p>',
      '[* hello.jpg *]'
    )
  end
  
  def test_image_with_link
    assert_equal_output(
      '<p><a href="http://metatribe.org"><img src="/images/hello.jpg" /></a></p>',
      '[* hello.jpg *]:http://metatribe.org'
    )
  end
  
  def test_image_with_size
    assert_equal_output(
      '<p><img height="90" src="/images/hello.jpg" width="160" /></p>',
      '[* hello.jpg 160x90 *]'
    )
  end
end
