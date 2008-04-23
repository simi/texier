require "#{File.dirname(__FILE__)}/../../test_helper"

class Texier::Modules::Table::TableElementTest < Test::Unit::TestCase
  def test_rows_should_return_rows_from_head_and_body
    table = Texier::Modules::Table::TableElement.new
    
    rows = [
      Texier::Element.new('tr'), 
      Texier::Element.new('tr'),
      Texier::Element.new('tr'),
    ]
    
    head = Texier::Element.new('thead')
    head << rows[0]
    table << head
    
    body = Texier::Element.new('tbody')
    body << rows[1] << rows[2]
    table << body

    assert_equal rows, table.rows.to_a
  end
end
