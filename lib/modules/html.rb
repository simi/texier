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
  class Html < Texier::Module
    block_element('html/tag') do
      attribute_name = e(/[a-zA-Z0-9\-_\:.]+/)
      attribute_value = e(/[^"> \n]+/) | (e('"').skip & everything_up_to(e('"').skip))
      
      attribute = attribute_name & e(/ *= */).skip & attribute_value
      attributes = attribute.zero_or_more.separated_by(/ +/).map(&Hash.method(:[]))
      
      # TODO: consider allowed_tags, allowed_classes & allowed_styles
      
      content = nothing
      
      html_element = dtd.block.pair.inject(nothing) do |result, tag|
        opening = e(/<#{tag} */).skip & attributes & e(/ *>/).skip
        closing = e(/<\/#{tag} *>/).skip
        
        result | (opening & content.up_to(closing)).map do |attributes, *content|
          Texier::Element.new(tag.name, content, attributes)
        end
      end
      
      # TODO: empty elements
      
      content << (
        (html_element | inline_element).zero_or_more & document & e(/\s*/).skip
      )
      
      html_element
    end
  end
end
