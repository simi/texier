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
  # This module contains methods that generate various types of parsing
  # expressions. If you want to use them in your class, you have to +include+
  # this module first.
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
  
  # Base class for all types of parsing expressions. If you want to create your
  # own expression class, you have to extend this class and (re)implement method
  # +parse_scanner+.
  class Expression
    include Generators
    
    def parse_string(string)
      parse_scanner(StringScanner.new(string))
    end
    
    alias_method :parse, :parse_string
    
    # TODO: create method parse_scanner, which will remember current position,
    # then calls the method try_parse_scanner (which should be implemented in
    # derived classes) and if that returns nil, reset the scanner position. In
    # derived classes, rename parse_scanner to try_parse_scanner and remove the
    # scanner position reset logic from it.
    
    # Test if this expression matches, but does not advance current position in
    # the parsed string.
    def peek(scanner)
      previous_pos = scanner.pos
      result = parse_scanner(scanner)
      scanner.pos = previous_pos

      result
    end
    
    # Modify the expression to return its result in array.
    def group
      map {|*results| [results]}
    end

    # Modify the expression to discard its result.
    def skip
      map {[]}
    end
  end
end