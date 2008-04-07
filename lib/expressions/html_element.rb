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

module Texier
  module Expressions
    
    # This module provides expressions for parsing html elements.
    module HtmlElement
      private
      
      # TODO: accept also uppercase tags
    
      # Expression that matches opening tag.
      def opening_tag(tag)
        e(/<#{tag} */).skip & attributes & e(/ *>/).skip
      end
    
      # Expression that matches closing tag.
      def closing_tag(tag)
        e(/<\/#{tag} *>/).skip
      end
    
      # Expression that matches empty tag.
      def empty_tag(tag)
        e(/<#{tag} */).skip & attributes & e(/ *\/>/).skip 
      end
    
      # Expression that matches attributes of a tag.
      def attributes
        processor.expressions[:attributes] ||= begin
          attribute = nothing
        
          # class
          classes = e(/[^"> \n]+/).one_or_more.separated_by(/ +/).group
          attribute << (e(/class *= *" */).map {'class'} & classes & e(/ *"/).skip)
        
          # TODO: unquoted class TODO: styles with ; at the end
        
          # style
          style_name = e(/[^:"> \n]+/)
          style_value = e(/[^:">;\n]+/)
          style = style_name & e(/ *: */).skip & style_value
          styles = style.one_or_more.separated_by(/ *; */).map(&Hash.method(:[]))
          attribute << (e(/style *= *" */).map {'style'} & styles & e(/ *"/).skip)
       
          # other attributes
          name = e(/[a-zA-Z0-9\-_\:.]+/)
          value = e(/[^"> \n]+/) | (e('"').skip & everything_up_to(e('"').skip))
        
          attribute << (name & e(/ *= */).skip & value)
          attribute << name.map {|n| [n, true]} # attribute without value
      
          attribute.zero_or_more.separated_by(/ +/).map(&Hash.method(:[]))
        end
      end
    
      # Expression that matches HTML element with given tags.
      # 
      # +tags+:: list of tags (should be instance of Texier::Dtd).
      # +content+:: expression that matches the content of the element.
      def html_element(tags, content)
        # First, pair elements...
        result = tags.pair.inject(nothing) do |result, tag|
          result | (opening_tag(tag) & content.up_to(closing_tag(tag))).map do |attributes, *content|
            build_html_element(tag, content, attributes)
          end
        end
      
        # ...then empty elements.
        tags.empty.inject(result) do |result, tag|
          result | empty_tag(tag).map do |attributes|
            build_html_element(tag, nil, attributes)
          end
        end
      end
    
      def build_html_element(tag, content, attributes)
        # Fail if tag is not allowed.
        return nil unless processor.tag_allowed?(tag.to_s)
      
        Texier::Element.new(
          tag.to_s, content, sanitize_attributes(tag, attributes)
        )
      end
    
      # TODO: move this to Processor class
      def sanitize_attributes(tag, attributes)
        attributes.inject({}) do |result, (name, value)|
          next(result) unless processor.attribute_allowed?(tag.to_s, name)
  
          case name
          when 'class'
            result[name] = value.select do |value|
              processor.class_allowed?(value)
            end
          when 'id'
            result[name] = value if processor.class_allowed?("\##{value}")
          when 'style'
            result[name] = value.reject do |name, value|
              !processor.style_allowed?(name)
            end
          else
            result[name] = value
          end
        
          result
        end
      end
    end
  end
end