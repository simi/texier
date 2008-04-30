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
  # Element in the Document Object Model.
  class Element
    attr_accessor :name
    attr_reader :content
    attr_reader :attributes

    def initialize(name = nil, content_or_attributes = nil, attributes = {})
      self.name = name

      if content_or_attributes.is_a?(Hash)
        @attributes = content_or_attributes
      else
        self.content = content_or_attributes
        @attributes = attributes
      end
    end

    # Set a content of the element. A content can be either string, or array of
    # child elements. Some of the child elements can be strings too.
    def content=(value)
      if value.is_a?(Array) && value.all? {|item| item.is_a?(String)}
        @content = value.join
      else
        @content = value
      end
      
      self
    end

    public
    
    # Access attributes using methods:
    # 
    # element.foo = 'bar' is the same as element.attributes['foo'] = 'bar'.
    def method_missing(method, *args)
      return super unless method.to_s =~ /[a-z_]+=?/

      method = method.to_s
      if method[-1] == ?=
        @attributes[method[0..-2]] = args.first
      else
        @attributes[method]
      end
    end

    # This is here just to suppress warning that foo.id is deprecated.
    def id
      @attributes['id']
    end

    def id=(value)
      @attributes['id'] = value
    end

    # The class attribute has to be accessed as +class_name+, because method
    # +class+ is already defined.
    def class_name=(value)
      @attributes['class'] = value
    end

    def class_name
      @attributes['class'] ||= []
    end

    def has_class_name?(value)
      @attributes['class'] && [*@attributes['class']].include?(value)
    end

    def add_class_name(value)
      @attributes['class'] = [*@attributes['class']].compact
      @attributes['class'] << value if value
      self
    end

    def remove_class_name(value)
      @attributes['class'].delete(value)
      self
    end

    def style
      @attributes['style'] ||= {}
    end

    # Apply modifier.
    def modify(modifier)
      modifier.each {|m| m.call(self)} if modifier
      self
    end
  end
end
