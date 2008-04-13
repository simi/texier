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

    block_element('table') do
      n = e("\n")
      space = e(/ */).skip
      separator = e(/\|+|$/).map do |pipes|
        count = pipes.count('|')
        count > 1 ? count : [nil]
      end

      cell_content = space & inline_element.one_or_more.group.up_to(space & separator)

      body_cell = cell_content.map {|*args| build_cell('td', *args)}
      head_cell = cell_content.map {|*args| build_cell('th', *args)}

      header_cell = e('*').skip & head_cell

      head_row = row(header_cell | head_cell)
      body_row = row(header_cell | body_cell)

      head_opening = e(/#{HEAD_SEPARATOR}\n/).skip
      head_closing = e(/\n#{HEAD_SEPARATOR}/).skip

      head_rows = head_opening & head_row.one_or_more.separated_by(n) & head_closing
      head = head_rows.map {|*rows| build('thead', rows)}

      body = (body_row | head_rows).one_or_more.separated_by(n).map do |*rows|
        build('tbody', rows)
      end

      table = (head & n.skip & body) | head | body
      table.map {|*blocks| build('table', blocks)}
    end

    private

    # Create an expression that parses table row.
    def row(cell)
      -e(HEAD_SEPARATOR) & e('|').skip & cell.one_or_more.map do |*cells|
        build('tr', cells)
      end
    end

    # Build table cell element.
    def build_cell(tag, content, column_span)
        build(tag, content, 'colspan' => column_span)
    end
  end
end