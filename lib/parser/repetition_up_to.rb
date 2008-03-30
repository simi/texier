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
  class RepetitionUpTo < Expression
    def initialize(expression, up_to, min)
      @expression = e(expression)
      @up_to = e(up_to)
      @min = min
    end

    def parse_scanner(scanner)
      previous_pos = scanner.pos
      results = []

      until up_to = @up_to.parse_scanner(scanner)
        return nil unless result = @expression.parse_scanner(scanner)
        results.concat(result)
      end

      if results.size >= @min
        [results] + up_to
      else
        scanner.pos = previous_pos
        nil
      end
    end
  end
end