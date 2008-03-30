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

module Texier::Parser
  # TODO: describe this
  class RepetitionWithSeparator < Expression
    def initialize(expression, separator, min)
      @expression = e(expression)
      @separator = e(separator)
      @min = min
    end

    def parse_scanner(scanner)
      # Ok, so what is this about?
      #
      # Let's say that i want to parse strings like this:
      #
      #   "foo,foo,foo,foo,foo"

      # First, i save current position of scanner, because if parsing fails, i
      # have to reset it to where it was before.
      previous_pos = scanner.pos
      results = []

      # Here is try to parse first occurence of "foo". I do this in separate
      # step, because there is no separator at the beggining. If it succeeds, i
      # save the result to results array, if not, i just continue anyway.
      result = @expression.parse_scanner(scanner)
      results.concat(result) if result

      # Now in this loop i try to parse pairs [",", "foo"] until there are no
      # more left. It can happen that the separator is matched, but "foo" is
      # not. In that case i need to reset scanner's position to just before last
      # separator, because this separator is actualy not part of list that i
      # want to parse.
      while true
        pos_before_separator = scanner.pos
        break unless @separator.parse_scanner(scanner)

        if result = @expression.parse_scanner(scanner)
          # If it matches, store only the "foo" and ignore separator.
          results.concat(result)
        else
          # If not, return position before last separator and end the loop.
          scanner.pos = pos_before_separator
          break
        end
      end

      # Here i check if enought occurences of "foo" was parsed. If yes, the
      # parsing is succesfull, if not, it fails.
      if results.size >= @min
        results
      else
        scanner.pos = previous_pos
        nil
      end
    end
  end
end