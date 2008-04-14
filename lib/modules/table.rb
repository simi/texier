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
    HEAD_SEPARATOR = / *\|[+-]{3,} */

    # NOTE: Texy! supports tables with only one head separator (if it is
    # anywhere except the end of the table, all rows after it become head rows.
    # If it is at the end, it is ignored). I won't support it yet, because i
    # don't believe the increased complexity of the code involved is actually
    # worth it.
    
    # TODO: rowspans
    
    # TODO: row, column and cell modifiers

    block_element('table') do
      n = e("\n").skip
      space = e(/ */).skip
      separator = e(/\|+|$/).map do |pipes|
        count = pipes.count('|')
        count > 1 ? count : [nil]
      end

      cell_content = space & inline_element.one_or_more.group.up_to(space & separator)

      body_cell = cell_content.map do |content, column_span|
        build_cell('td', content, column_span)
      end
      
      head_cell = cell_content.map do |content, column_span|
        build_cell('th', content, column_span)
      end

      header_cell = e('*').skip & head_cell
      
      row_opening = -e(HEAD_SEPARATOR) & e('|').skip

      head_row = row_opening & (header_cell | head_cell).one_or_more.map do |*cells|
        build('tr', cells)
      end
      
      body_row = row_opening & (header_cell | body_cell).one_or_more.map do |*cells|
        build('tr', cells)
      end
      
      
      head_opening = e(/#{HEAD_SEPARATOR}\n/).skip
      head_closing = e(/\n#{HEAD_SEPARATOR}/).skip

      head_rows = head_opening & head_row.one_or_more.separated_by(n) & head_closing
      head = head_rows.map {|*rows| build('thead', rows)}

      body = (body_row | head_rows).one_or_more.separated_by(n).map do |*rows|
        build('tbody', rows)
      end

      table = (modifier & n).maybe & ((head & n & body) | head | body)
      table.map do |modifier, *blocks|
        build('table', blocks).modify(modifier)
      end
    end

    private

    # Build table cell element.
    def build_cell(tag, content, column_span)
      build(tag, content, 'colspan' => column_span)
    end
  end
end