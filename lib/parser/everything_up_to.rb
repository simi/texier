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
  class EverythingUpTo < Expression
    def initialize(expression)
      @expression = e(expression)
    end
    
    def parse_scanner(scanner)
      result = ''
      
      until stop = @expression.parse_scanner(scanner)
        return nil unless char = scanner.getch
        result << char
      end
      
      result.empty? ? nil : [result] + stop
    end
  end

  module Generators
    def everything_up_to(expression)
      EverythingUpTo.new(expression)
    end
    
    # Expression that matches text inside quotes.
    def quoted_text(opening, closing = opening)
      e(opening).skip & everything_up_to(e(closing).skip)
    end
  end
end