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
  # Helper method to generate various types of parsing expressions.
  module Generators
    # Create expression from string or regexp literals. If passed argument is
    # already Expression, it is returned unchanged.
    def expression(something, &block)
      result = case something
      when ::String then String.new(something)
      when ::Regexp then Regexp.new(something)
      when Expression then something
      else raise Error, "I dont know how to create expression from #{something.class.name}"
      end
      
      result = result.map(&block) if block_given?
      result
    end

    alias_method :e, :expression
  end
  
  # Base class for parsing expressions.
  class Expression
    include Generators
    
    def parse_string(string)
      parse_scanner(StringScanner.new(string))
    end
    
    alias_method :parse, :parse_string
    
    def peek(scanner)
      previous_pos = scanner.pos
      result = parse_scanner(scanner)
      scanner.pos = previous_pos

      result
    end
  
    # TODO: describe this
    def group
      map {|*results| [results]}
    end

    # Match expression, but discard the result.
    def skip
      map {[]}
    end
  end
end