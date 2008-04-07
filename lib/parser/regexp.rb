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
    def initialize(regexp = //)
      @regexp = regexp
    end
    
    # TODO: if pattern contains captures, return them as array. For this i will
    # need to replace StringScanner my own class though.

    def parse_scanner(scanner)
      result = scanner.scan(@regexp)
      result ? [result] : nil
    end
  end
  
  module Generators
    # Expression that matches end of line.
    def eol
      e(/$/).skip
    end
  end
end