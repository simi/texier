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
  # Expression that matches when regexp matches.
  class Regexp < Expression
    def initialize(regexp)
      @regexp = regexp
      @captures = count_captures
    end
    
    def parse_scanner(scanner)
      if result = scanner.scan(@regexp)
        if @captures > 0
          collect_captures(scanner)
        else
          [result]
        end
      else
        nil
      end
    end
    
    private
    
    # Count number of subgroups in regexp so i can return them when the
    # expression matches. This needs to be done this way, because there is no
    # way how to get number of subgroups from StringScanner (at least i don't
    # know of any).
    def count_captures
      # Count number of opening parenthesis that are neither escaped, nor
      # followed by question mark (that should equal to number of subgroups).
      @regexp.source.scan(/(?:[^\\]|^)\((?!\?)/).size
    end
    
    # Collect captured subexpression from StringScanner object.
    def collect_captures(scanner)
      (1..@captures).inject([]) do |result, index|
        result << scanner[index]
        result
      end
    end
  end
  
  module Generators
    # Expression that matches end of line.
    def eol
      # OPTIMIZE: Don't use regexps here, create special class for it.
      e(/$/).skip
    end
  end
end