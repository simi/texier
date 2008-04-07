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
  class Figure < Base
    block_element('figure') do
      figure = image & e(/ *\*{3,} */).skip & everything_up_to(e(/$/).skip)
      figure = figure.map do |image, description|
        Texier::Element.new(
          'div', [image, Texier::Element.new('p', description)],
          'class' => 'figure'
        )
      end
    end
  end
end
