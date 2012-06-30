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
  # Ordered choice.
  class Choice < Expression
    attr_reader :expressions

    def initialize(*expressions)
      @expressions = expressions.map(&method(:e))
    end

    def parse_scanner(scanner)
      @expressions.each do |expression|
        if result = expression.parse_scanner(scanner)
          return result
        end
      end

      nil
    end

    def << (expression)
      @expressions << expression
    end
  end
  
  class Expression
    def | (other)
      if other.is_a?(Choice)
        Choice.new(self, *other.expressions)
      else
        Choice.new(self, other)
      end
    end
  end
  
  module Generators
    # Create expression that never matches anything. It is actualy Choice,
    # so other expression can be added to it later using << operator.
    def nothing
      Choice.new
    end
  end
end