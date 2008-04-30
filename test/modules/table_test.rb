require "#{File.dirname(__FILE__)}/../test_helper"

class Texier::Modules::TableTest < Test::Unit::TestCase
  def test_table
    assert_equal_output(
      '<table><tbody>' \
        '<tr><td>one one</td><td>one two</td></tr>' \
        '<tr><td>two one</td><td>two two</td></tr>' \
        '</tbody></table>',
      '
      |one one|one two|
      |two one|two two|'.unindent
    )
  end

  def test_last_cell_separator_should_be_optional
    assert_equal_output(
      '<table><tbody>' \
        '<tr><td>one</td><td>two</td></tr>' \
        '</tbody></table>',
      '|one|two'
    )
  end
  
  def test_table_cell_with_inline_elements
    assert_equal_output(
      '<table><tbody>' \
        '<tr><td><em>one</em></td><td>two</td></tr>' \
        '</tbody></table>',
      '| *one* | two |'
    )
  end
  
  def test_table_head
    assert_equal_output(
      '<table><thead><tr><th>one</th><th>two</th></tr></thead></table>',
      '
      |--------
      |one|two|
      |--------'.unindent
    )
  end
  
  def test_table_head_with_many_rows
    assert_equal_output(
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
  
  def test_table_with_head_rows_at_the_top
    assert_equal_output(
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
  
  def test_table_with_head_rows_in_the_middle
    assert_equal_output(
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
  
  def test_table_head_rows_in_various_places
    assert_equal_output(
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
  
  def test_header_cells_outside_head_row
    assert_equal_output(
      '<table><tbody>' \
        '<tr><th>one one</th><td>one two</td></tr>' \
        '<tr><th>two one</th><td>two two</td></tr>' \
        '</tbody></table>',
      '
      |* one one|one two|
      |* two one|two two|'.unindent
    )
  end
  
  def test_cell_spanning_more_columns
    assert_equal_output(
      '<table><tbody>' \
        '<tr><td colspan="2">one</td></tr>' \
        '<tr><td>two one</td><td>two two</td></tr>' \
        '</tbody></table>',
      '
      |one           ||
      |two one|two two|'.unindent
    )
    
    assert_equal_output(
      '<table><tbody>' \
        '<tr><td colspan="3">one</td></tr>' \
        '<tr><td>two one</td><td>two two</td><td>two three</td></tr>' \
        '</tbody></table>',
      '
      |one                    |||
      |two one|two two|two three|'.unindent
    )
  end
  
  def test_single_column_cell_and_multi_column_cell_in_single_row
    assert_equal_output(
      '<table><tbody>' \
        '<tr><td>one one</td><td colspan="2">one two</td></tr>' \
        '<tr><td>two one</td><td>two two</td><td>two three</td></tr>' \
        '</tbody></table>',
      '
      |one one|one two         ||
      |two one|two two|two three|'.unindent
    )
  end
  
#  def test_cell_spanning_more_rows
#    assert_equal_output(
#      '<table><tbody>' \
#        '<tr><td rowspan="2">one one</td><td>one two</td></tr>' \
#        '<tr><td>two two</td></tr>' \
#        '</tbody></table>',
#      '
#      |one one|one two|
#      |^      |two two|'.unindent
#    )
#  end
  
  def test_table_with_modifier
    assert_equal_output(
      '<table class="foo"><tbody>' \
        '<tr><td>one one</td><td>one two</td></tr>' \
        '<tr><td>two one</td><td>two two</td></tr>' \
        '</tbody></table>',
      '
      .[foo]
      |one one|one two|
      |two one|two two|'.unindent
    )
  end
  
  def test_table_row_with_modifier
    assert_equal_output(
      '<table><tbody>' \
        '<tr class="foo"><td>one one</td><td>one two</td></tr>' \
        '<tr><td>two one</td><td>two two</td></tr>' \
        '</tbody></table>',
      '
      |one one|one two| .[foo]
      |two one|two two|'.unindent
    )
  end
  
  def test_table_cell_with_modifier
    assert_equal_output(
      '<table><tbody>' \
        '<tr><td class="foo">one</td><td>two</td></tr>' \
        '</tbody></table>',
      '|one .[foo]|two|'
    )
  end

  def test_cell_count_equalization
    assert_equal_output(
      '<table><tbody>' \
        '<tr><td>one one</td><td>one two</td></tr>' \
        '<tr><td>two one</td><td></td></tr>' \
        '</tbody></table>',
      '
      |one one|one two|
      |two one|'.unindent
    )
  end
  
  def test_cell_count_equalization_with_column_spans
    assert_equal_output(
      '<table><tbody>' \
        '<tr><td colspan="2">one one</td></tr>' \
        '<tr><td>two one</td><td></td></tr>' \
        '</tbody></table>',
      '
      |one one||
      |two one|'.unindent
    )
  end
  
  def test_cell_count_equalization_with_head_row
    assert_equal_output(
      '<table><thead>' \
        '<tr><th>one one</th><th></th></tr>' \
        '</thead><tbody>' \
        '<tr><td>two one</td><td>two two</td></tr>' \
        '</tbody></table>',
      '
      |----------------
      |one one|
      |----------------
      |two one|two two|'.unindent
    )
  end
  
  def test_odd_and_even_classes
    @texier = Texier::Base.new
    @texier.table_module.odd_class = 'odd'
    @texier.table_module.even_class = 'even'
    
    assert_equal_output(
      '<table><tbody>' \
        '<tr class="even"><td>one one</td><td>one two</td></tr>' \
        '<tr class="odd"><td>two one</td><td>two two</td></tr>' \
        '</tbody></table>',
      '
      |one one|one two|
      |two one|two two|'.unindent
    )
  end
  
end
