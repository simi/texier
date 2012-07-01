#
# Copyright (c) 2012 Josef Šimánek <retro@ballgag.cz>
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

module Texier
  class StringScanner
    attr_accessor :string
    attr_accessor :pos
    attr_accessor :results

    def initialize(string)
      self.string = string
      self.pos = 0
      self.results = []
    end

    def peek(to)
      string.slice(pos, to)
    end

    def rest
      string[pos, string.length - pos]
    end

    def getch
      s = string.slice(self.pos)
      self.pos = self.pos + 1
      s
    end

    def scan(regexp)
      if (rest =~ regexp) == 0
        self.results = rest.match(regexp)
        self.pos = self.pos + self.results[0].length
        return results[0]
      else
        self.results = []
        return nil
      end
    end

    def [](index)
      self.results[index]
    end
  end
end
