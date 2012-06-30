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
  class Map < Expression
    def initialize(expression, &block)
      @expression = e(expression)
      @block = block
    end

    def parse_scanner(scanner)
      previous_pos = scanner.pos
      
      if result = apply(@expression.parse_scanner(scanner))
        result
      else
        scanner.pos = previous_pos
        nil
      end
    end

    private

    def apply(result)
      if result && result = @block.call(*result)
        result.is_a?(Array) ? result : [result]
      else
        nil
      end
    end
  end

  class Expression
    def map(&block)
      Map.new(self, &block)
    end

    # Modify the expression to discard its result.
    # OPTIMIZE: foo.skip.skip.skip should be the same as foo.skip
    def skip
      map {[]}
    end
    
    # Modify the expression to return its result in array.
    def group
      map {|*results| [results]}
    end
  end
end
