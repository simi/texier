require "#{File.dirname(__FILE__)}/../../test_helper"

class Texier::Modules::Table::RowElementTest < Test::Unit::TestCase
  def test_cell_count
    row = Texier::Modules::Table::RowElement.new
    assert_equal 0, row.cell_count
    
    row << Texier::Element.new('td')
    row << Texier::Element.new('td')
    assert_equal 2, row.cell_count
    
    row << Texier::Element.new('td', 'colspan' => 3)
    assert_equal 5, row.cell_count
  end
end
