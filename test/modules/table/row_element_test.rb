require "#{File.dirname(__FILE__)}/../../test_helper"

class Texier::Modules::Table::RowElementTest < Test::Unit::TestCase
  def test_cell_count_should_be_zero_when_row_contains_no_cells
    row = Texier::Modules::Table::RowElement.new
    
    assert_equal 0, row.cell_count
  end
end
