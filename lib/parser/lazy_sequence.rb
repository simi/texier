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
  # TODO: describe this.
  class LazySequence < Texier::Parser::Expression
    def initialize(first, second)
      @first = e(first)
      @second = e(second)
    end

    def parse_scanner(scanner)
      previous_pos = scanner.pos

      first = @first.parse_scanner_lazily(scanner, @second)
      second = @second.parse_scanner(scanner)

      if first && second
        first + second
      else
        scanner.pos = previous_pos
        nil
      end
    end
  end

  # Monkey-patch lazy parsing support to these classes.
  
  # TODO: This is not very DRY. Refactor!
  
  class Expression
    def parse_scanner_lazily(scanner, stop)
      parse_scanner(scanner)
    end

    # Create lazy sequence.
    def up_to(other)
      LazySequence.new(self, other)
    end
  end

  class Choice
    def parse_scanner_lazily(scanner, stop)
      @expressions.each do |expression|
        if result = expression.parse_scanner_lazily(scanner, stop)
          return result
        end
      end

      nil
    end
  end
  
  class Map
    def parse_scanner_lazily(scanner, stop)
      apply(@expression.parse_scanner_lazily(scanner, stop))
    end
  end
  
  class Repetition
    def parse_scanner_lazily(scanner, stop)
      previous_pos = scanner.pos
      results = []

      until stop.peek(scanner)
        if result = @expression.parse_scanner_lazily(scanner, stop)
          results.concat(result)
        else
          break
        end
      end

      if results.size < @min
        scanner.pos = previous_pos
        nil
      else
        results
      end
    end
  end
  
  class Sequence
    def parse_scanner_lazily(scanner, stop)
      previous_pos = scanner.pos
      results = []

      @expressions.each do |expression|
        if result = expression.parse_scanner_lazily(scanner, stop)
          results.concat(result)
        else
          scanner.pos = previous_pos
          return nil
        end
      end

      results
    end
  end
  
end
