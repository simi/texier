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
  class Repetition < Expression
    def initialize(expression, min)
      @expression = e(expression)
      @min = min
    end

    def parse_scanner(scanner)
      previous_pos = scanner.pos
      results = []

      while result = @expression.parse_scanner(scanner)
        results.concat(result)
      end

      if results.size < @min
        scanner.pos = previous_pos
        nil
      else
        results
      end
    end

    # TODO: describe this
    def separated_by(separator)
      result = @expression & (e(separator).skip & @expression).at_least([@min - 1, 0].max)
      result |= e('').skip if @min.zero?
      result
    end
  end

  class Expression
    # Zero or more repetitions.
    def zero_or_more
      Repetition.new(self, 0)
    end

    # One or more repetitions.
    def one_or_more
      Repetition.new(self, 1)
    end
    
    # At least +min+ repetitions.
    def at_least(min)
      Repetition.new(self, min)
    end
  end
end
