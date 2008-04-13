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

module Texier::Modules
  class Table < Base
    HEADER_SEPARATOR = / *\|[+-]{3,} */
    
    block_element('table') do
      n = e("\n")
      
      header_opening = e(/#{HEADER_SEPARATOR}\n/).skip
      header_closing = e(/\n#{HEADER_SEPARATOR}/).skip
      
      header = header_opening & row('th').one_or_more.separated_by(n) & header_closing
      header = header.map do |*rows|
        Texier::Element.new('thead', rows)
      end

      body = row('td').one_or_more.separated_by(n).map do |*rows|
        Texier::Element.new('tbody', rows)
      end
      
      (header | body).one_or_more.separated_by(n).map do |*blocks|
        Texier::Element.new('table', blocks)
      end
    end
    
    private
    
    # Create an expression that parses table row.
    def row(cell_tag)
      @cell_separator ||= e(/ *\| */).skip
      @cell ||= inline_element.one_or_more.up_to(@cell_separator | e(/$/))
      
      cell = @cell.map do |*content|
        Texier::Element.new(cell_tag, content)
      end
      
      -e(HEADER_SEPARATOR) & @cell_separator & cell.one_or_more.map do |*cells|
        Texier::Element.new('tr', cells)
      end
    end
  end
end
