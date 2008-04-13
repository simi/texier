require "#{File.dirname(__FILE__)}/../test_helper"

class Texier::Modules::TableTest < Test::Unit::TestCase
  def test_table
    assert_output(
      '<table><tbody>' \
        '<tr><td>one one</td><td>one two</td></tr>' \
        '<tr><td>two one</td><td>two two</td></tr>' \
        '</tbody></table>',
      '
      |one one|one two|
      |two one|two two|'.unindent
    )
  end
  
  def test_table_cell_with_inline_elements
    assert_output(
      '<table><tbody>' \
        '<tr><td><em>one</em></td><td>two</td></tr>' \
        '</tbody></table>',
      '| *one* | two |'
    )
  end
  
  def test_table_header
    assert_output(
      '<table><thead><tr><th>one</th><th>two</th></tr></thead></table>',
      '
      |--------
      |one|two|
      |--------'.unindent
    )
  end
  
  def test_table_header_with_many_rows
    assert_output(
      '<table><thead>' \
        '<tr><th>one one</th><th>one two</th></tr>' \
        '<tr><th>two one</th><th>two two</th></tr>' \
        '</thead></table>',
      '
      |----------------
      |one one|one two|
      |two one|two two|
      |----------------'.unindent
    )
  end
  
  def test_table_with_header_at_the_top
    assert_output(
      '<table><thead>' \
        '<tr><th>one one</th><th>one two</th></tr>' \
        '</thead><tbody>' \
        '<tr><td>two one</td><td>two two</td></tr>' \
        '</tbody></table>',
      '
      |----------------
      |one one|one two|
      |----------------
      |two one|two two|'.unindent
    )
  end
  
  def test_table_with_header_in_the_middle
    assert_output(
      '<table><tbody>' \
        '<tr><td>one one</td><td>one two</td></tr>' \
        '<tr><th>two one</th><th>two two</th></tr>' \
        '<tr><td>three one</td><td>three two</td></tr>' \
        '</tbody></table>',
      '
      |one one  |one two  |
      |--------------------
      |two one  |two two  |
      |--------------------
      |three one|three two|'.unindent
    )
  end
  
  def test_table_with_many_headers
    assert_output(
      '<table><thead>' \
        '<tr><th>one one</th><th>one two</th></tr>' \
        '</thead><tbody>' \
        '<tr><td>two one</td><td>two two</td></tr>' \
        '<tr><th>three one</th><th>three two</th></tr>' \
        '</tbody></table>',
      '
      |--------------------
      |one one  |one two  |
      |--------------------
      |two one  |two two  |
      |--------------------
      |three one|three two|
      |--------------------'.unindent
    )
  end
end
