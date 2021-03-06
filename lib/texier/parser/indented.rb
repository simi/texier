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
  class Indented < Expression
    def initialize(expression, indent_re)
      @expression = e(expression)
      @indent_re = indent_re || /^([ \t]+|$)/
    end

    def parse_scanner(scanner)
      # Try to unindent the string.
      indented_string, indent_lengths = unindent(scanner.rest)
          
      # Fail right away if no line was indented.
      return nil if indented_string.empty?
          
      # Parse indented part of the string (now unindented).
      inner_scanner = StringScanner.new(indented_string)
      result = @expression.parse_scanner(inner_scanner)
          
      # How many lines did the inner expression consume.
      lines = indented_string[0..inner_scanner.pos].count("\n")
          
      # Length of the parsed string (including indents)
      length = inner_scanner.pos + indent_lengths[0..lines].inject(0) {|o, l| o + l}
          
      # Update main scanner position.
      scanner.pos += length
          
      result
    end
        
    private
        
    EMPTY_LINE = /^[ \t]*$/
        
    def unindent(string)
      # Take just the indented part of the string and find shortest indentation.
      indented_lines = []
      min = string.length
          
      string.each_line do |line|
        break unless indent = line.slice!(@indent_re)
            
        # Empty line doesn't count.
        min = [indent.length, min].min unless line =~ EMPTY_LINE
        indented_lines << (indent + line)
      end
          
      # Unindent it and save the lengths of indents.
      result = ''
      lengths = []
          
      indented_lines.each do |line|
        unindented_line = line[min..-1]
        unindented_line = "\n" if unindented_line.to_s.empty?
            
        result << unindented_line
        lengths << (line.length - unindented_line.length)
      end
          
      [result, lengths]
    end
  end
  
  class Expression
    def indented(indent_re = nil)
      Indented.new(self, indent_re)
    end
  end
end