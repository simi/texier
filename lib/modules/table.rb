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
    
    # TODO: column and cell modifiers

    block_element('table') do
      n = e("\n").skip
      eol = e(/$/).skip
      space = e(/ */).skip
      pipe = e('|')
      
      column_span = e(/\|*(?=\|)/).map do |pipes|
        count = pipes.count('|')
        count > 0 ? count + 1 : [nil]
      end

      cell_content = inline_element.one_or_more.group & space & column_span
      cell = space & cell_content.up_to(space & +pipe)

      body_cell = cell.map do |content, column_span|
        build_cell('td', content, column_span)
      end
      
      head_cell = cell.map do |content, column_span|
        build_cell('th', content, column_span)
      end
      
      header_cell = e('*').skip & head_cell
      
      body_cells = (header_cell | body_cell).one_or_more.separated_by(pipe).group
      
      row_start = -e(HEAD_SEPARATOR) & pipe.skip
      row_stop = pipe.maybe.skip & modifier.maybe & eol

      body_row = (row_start & body_cells & row_stop).map do |cells, modifier|
        build('tr', cells).modify(modifier)
      end
      
      head_cells = head_cell.one_or_more.separated_by(pipe).group
      
      head_row = (row_start & head_cells & row_stop).map do |cells, modifier|
        build('tr', cells).modify(modifier)
      end

      head_start = e(/#{HEAD_SEPARATOR}\n/).skip
      head_stop = e(/\n#{HEAD_SEPARATOR}/).skip

      head_rows = head_start & head_row.one_or_more.separated_by(n) & head_stop
      head = head_rows.map do |*rows|
        build('thead', rows)
      end
      
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