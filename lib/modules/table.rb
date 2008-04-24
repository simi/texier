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

    # TODO: column modifiers

    options(
      # CSS class for odd rows.
      :odd_class => nil,
      
      # CSS class for even rows.
      :even_class => nil
    )

    block_element('table') do
      n = e("\n").skip

      head_row = row('th')

      head_start = e(/#{HEAD_SEPARATOR}\n/).skip
      head_stop = e(/\n#{HEAD_SEPARATOR}/).skip

      head_rows = head_start & head_row.one_or_more.separated_by(n) & head_stop
      head = head_rows.map do |*rows|
        build('thead', rows)
      end

      body_row = row('td')

      body = (body_row | head_rows).one_or_more.separated_by(n).map do |*rows|
        build('tbody', rows)
      end

      table = (modifier & n).maybe & ((head & n & body) | head | body)
      table.map do |modifier, *blocks|
        table = build('table', blocks)
        table.modify(modifier)
        apply_classes(table)
        # apply_row_spans(table)
        equalize_cell_count(table)
        
        table
      end
    end

    private

    def row(cell_tag)
      main_cell = cell(cell_tag)
      head_cell = e('*').skip & cell('th')

      cells = (head_cell | main_cell).one_or_more.separated_by('|').group

      row_start = -e(HEAD_SEPARATOR) & e('|').skip
      row_stop = e('|').maybe.skip & modifier.maybe & eol

      (row_start & cells.up_to(row_stop)).map do |cells, modifier|
        build('tr', cells).modify(modifier)
      end
    end

    def cell(tag)
      space = e(/ */).skip

      separator = e(/ *(?:(?:\|*(?=\|))|$)/).map do |pipes|
        count = pipes.count('|')
        count > 0 ? count + 1 : [nil]
      end

      cell = space & inline_element.one_or_more.group
      cell = cell.up_to(space & modifier.maybe & separator)
      cell.map do |content, modifier, column_span|
        build(tag, content, 'colspan' => column_span).modify(modifier)
      end
    end
    
    # Apply classes to mark odd/even rows.
    def apply_classes(table)
      return unless odd_class || even_class
      
      rows = Rows.new(table)
      
      rows.each_with_index do |row, index|
        row.add_class_name(index % 2 == 0 ? even_class : odd_class)
      end
    end

    # Modify table so it has the same number of cells in all rows.
    def equalize_cell_count(table)
      # Find maximum number of cells for all rows.
      rows = Rows.new(table)

      max_cell_count = rows.inject(0) do |max_cell_count, row|
        [max_cell_count, cell_count_of(row)].max
      end

      rows.each do |row|
        force_cell_count(row, max_cell_count)
      end
    end

    # Ensure that the +row+ has +count+ cells by appending empty cells if
    # necessary.
    def force_cell_count(row, count)
      tag = row.content.last.name || 'td'

      (count - cell_count_of(row)).times do
        row << Texier::Element.new(tag)
      end
    end

    # Returns number of cells in this row.
    # 
    # This method respects cells that spans several columns. Every such cell is
    # counted as many times, as many columns it spans.
    def cell_count_of(row)
      row.content.inject(0) do |count, cell|
        count + (cell.colspan || 1)
      end
    end

    # Helper class to enumerate table rows.
    class Rows < Struct.new(:table)
      include Enumerable

      def each(&block)
        table.content.each do |rows|
          rows.content.each(&block)
        end
      end
    end
  end
end