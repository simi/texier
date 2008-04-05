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

require "#{File.dirname(__FILE__)}/../expressions/html_element"

module Texier::Modules
  # This module processes html elements.
  class Html < Texier::Module
    include Texier::Expressions::HtmlElement
    
    block_element('html/tag') do
      content = nothing
      element = html_element(dtd.block, content)
      
      content << (
        (element | inline_element).zero_or_more & document & e(/\s*/).skip
      )
      
      element
    end
    
    inline_element('html/tag') do
      html_element(dtd.inline, inline_element.zero_or_more)
    end
    
    # TODO: HTML comments
  end
end
