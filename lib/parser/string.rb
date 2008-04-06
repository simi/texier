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
  # Expression that matches a string.
  class String < Expression
    def initialize(string = '')
      @string = string
    end

    def parse_scanner(scanner)
      # FIXME: i think this is not multibyte safe
      
      if scanner.peek(@string.length) == @string
        scanner.pos += @string.length
        [@string]
      else
        nil
      end
    end
  end
end