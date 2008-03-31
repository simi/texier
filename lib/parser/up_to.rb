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
  class UpTo < Texier::Parser::Expression
    def initialize(expression, stop)
      @expression = e(expression)
      @stop = e(stop)
    end

    def parse_scanner(scanner)
      previous_pos = scanner.pos
      inner_string = ''
      
      until stop = @stop.parse_scanner(scanner)
        break unless char = scanner.getch
        inner_string << char
      end
      
      return nil unless stop
      
      inner_scanner = StringScanner.new(inner_string)
      inner_result = @expression.parse_scanner(inner_scanner)
        
      if inner_result && inner_scanner.eos?
        inner_result + stop
      else
        scanner.pos = previous_pos
        nil
      end
    end
  end

  class Expression
    def up_to(stop)
      UpTo.new(self, stop)
    end
  end
  
  module Generators
    # Expression that matches text inside quotes.
    def quoted_text(opening, closing = opening)
      e(opening).skip & everything.up_to(e(closing).skip)
    end
  end
end