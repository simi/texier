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
  # Class for querying HTML Document type definition.
  class Dtd
    
    # This class contains all information about particular HTML tag.
    class Tag
      attr_reader :name
      alias_method :to_s, :name
      
      def initialize(name, properties)
        @name = name
        @block = properties[:block]
        @empty = properties[:empty]
      end
    
      # Is it block-level element tag?
      def block?
        @block
      end
      
      # Is it inline element tag?
      def inline?
        !@block
      end
      
      # Is it pair element (<foo>...</foo>) tag?
      def pair?
        !@empty
      end
      
      # Is it empty element (<foo />) tag?
      def empty?
        @empty
      end
    end
    
    TAGS = {
      'a' => {:block => false},
      'b' => {:block => false, :strict => false},
      'div' => {:block => true},
      'p' => {:block => true}
      
      # TODO: complete this
    }.map {|name, properties| Tag.new(name, properties)}
    
    def initialize(tags = TAGS)
      @tags = tags
    end
    
    include Enumerable
    
    def each(&block)
      @tags.each(&block)
    end
    
    def include?(tag_name)
      @tags.any? {|tag| tag.name == tag_name}
    end
    
    # Tags for block-level elements
    def block
      select {|tag| tag.block?}
    end
    
    # Tags for inline element
    def inline
      select {|tag| tag.inline?}
    end
    
    # Tags for pair elements
    def pair
      select {|tag| tag.pair?}
    end
    
    # Tags for empty element
    def empty
      select {|tag| tag.empty?}
    end
    
    def select(&block)
      self.class.new(@tags.select(&block))
    end
  end
end
