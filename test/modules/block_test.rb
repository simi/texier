require "#{File.dirname(__FILE__)}/../test_helper"

# Test case for Texier::Modules::Block class
class BlockTest < Test::Unit::TestCase
  def test_text_block
    assert_output 'hello world', "/-- text\nhello world\n\\--"
  end
  
  def test_text_block_with_multiline_content
    assert_output(
      'first line<br />second line',
      "/-- text\nfirst line\nsecond line\n\\--"
    )
  end
  
  def test_text_block_should_not_process_texier_elements
    assert_output '*hello*', "/-- text\n*hello*\n\\--"
  end
  
  def test_text_block_should_escape_html_tags
    assert_output '&lt;em&gt;hello&lt;/em&gt;', "/-- text\n<em>hello</em>\n\\--"
  end
  
  def test_code_block
    assert_output(
      '<pre><code>puts "hello world"</code></pre>',
      "/-- code\nputs \"hello world\"\n\\--"
    )
  end
  
  def test_code_block_with_language
    assert_output(
      '<pre class="ruby"><code>puts "hello world"</code></pre>',
      "/-- code ruby\nputs \"hello world\"\n\\--"
    )
  end
  
  def test_code_block_with_modifier
    assert_output(
      '<pre class="rails"><code>render :text => "hello world"</code></pre>',
      "/-- code .[rails]\nrender :text => \"hello world\"\n\\--"
    )
  end
  
  def test_code_block_with_language_and_modifier
    assert_output(
      '<pre class="ruby rails"><code>render :text => "hello world"</code></pre>',
      "/-- code ruby .[rails]\nrender :text => \"hello world\"\n\\--"
    )
  end
  
  def test_html_block
    assert_output 'hello <em>world</em>', "/-- html\nhello <em>world</em>\n\\--"
  end
  
  def test_div_block
    assert_output '<div><p>hello world</p></div>', "/-- div\nhello world\n\\--"
  end
  
  def test_nested_div_blocks
    assert_output(
      '<div><p>outer</p><div><p>nested</p></div></div>',
      "/-- div\nouter\n/-- div\nnested\n\\--\n\\--"
    )
  end
  
  def test_div_block_with_modifier
    assert_output(
      '<div class="foo"><p>hello world</p></div>',
      "/-- div .[foo]\nhello world\n\\--"
    )
  end
end
