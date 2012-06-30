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
  # This module provides block quotations.
  class BlockQuote < Base
    block_element('blockquote') do
      content = block_element.one_or_more.separated_by(/\n+/).group
      block_quote = (modifier & e("\n").skip).maybe \
        & content.indented(/^>( |$)/) & (e("\n>").skip & link).maybe
      
      block_quote.map do |modifier, content, cite_url|
        element = build('blockquote', content, :cite => cite_url)
        element.modify(modifier)
      end
    end
  end
end