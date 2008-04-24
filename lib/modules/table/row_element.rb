# 
# Copyright (c) 2008 Adam Ciganek <adam.ciganek@gmail.com>
# 
# This file is part of Texier.
# 
# Texier is free software: you can redistribute it and/or modify it under the
# terms of the GNU General Public License version 2 as published by the Free
# Software Foundation.
# 
# Texier is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along with
# Texier. If not, see <http://www.gnu.org/licenses/>.
# 
# For more information please visit http://code.google.com/p/texier/
# 

class Texier::Modules::Table::RowElement < Texier::Element
  def initialize(cells = [])
    super('tr', cells)
  end

  # Returns number of cells in this row.
  # 
  # This method respects cells that spans several columns. Every such cell is
  # counted as many times, as many columns it spans.
  # 
  # For example, this method returns 4 for row like this:
  #   <tr><td>foo</td><td colspan="3">bar</td></tr>
  def cell_count
    content.inject(0) do |count, cell|
      count + (cell.colspan || 1)
    end
  end

  # Ensure that the row has +count+ cells by appending empty cells if necessary.
  def ensure_cell_count(count)
    tag = content.last.name || 'td'
    
    (count - cell_count).times do
      self << Texier::Element.new(tag)
    end
  end
end