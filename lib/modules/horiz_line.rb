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

module Texier::Modules
  class HorizLine < Base
    # NOTE: Texy! supports classes and modifiers here, but i don't think they
    # are realy necessary. KISS.
    
    block_element('horizline') do
      ['-', '*'].inject(nothing) do |result, style|      
        result | e(/^#{Regexp.quote(style)}{3,} *$/).map {build('hr')}
      end
    end
  end
end
