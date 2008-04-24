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

# This class represents a table element. It extends Texier::Element with some
# useful table-related features.
class Texier::Modules::Table::TableElement < Texier::Element
  def initialize(rows = [])
    super('table', rows)
    
    equalize_cell_count
  end
  
  # Return array-like object that enumerates all rows of this table.
  def rows
    @rows ||= Rows.new(self)
  end

  class Rows
    include Enumerable
    
    def initialize(table)
      @table = table
    end
    
    def each(&block)
      @table.content.each do |rows|
        rows.content.each(&block)
      end
    end
  end
  
  private
  
  def equalize_cell_count
    # Find maximum number of cells for all rows.
    max_cell_count = rows.inject(0) do |max_cell_count, row|
      [max_cell_count, row.cell_count].max
    end
   
    rows.each do |row|
      row.ensure_cell_count(max_cell_count)
    end
  end
end   
