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

      if results.size >= @min
        results
      else
        scanner.pos = previous_pos
        nil
      end
    end

    def separated_by(separator)
      RepetitionWithSeparator.new(@expression, separator, @min)
    end

    def up_to(stop)
      RepetitionUpTo.new(@expression, stop, @min)
    end
  end
  
  class Expression
    # Expression that matches zero or more occurences of this expression.
    def zero_or_more
      Repetition.new(self, 0)
    end

    def one_or_more
      Repetition.new(self, 1)
    end
  end
end