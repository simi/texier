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
  class Link < Texier::Module
    include Texier::Expressions::Link
    
    # TODO: obfuscate emails, shorten urls, ...
    
    def initialize
      @references = {}
    end
    
    inline_element('link/url') do
      e(Texier::Expressions::Link::URL).map do |url|
        build_link(url, url)
      end
    end
    
    inline_element('link/email') do
      e(Texier::Expressions::Link::EMAIL).map do |email|
        build_link(email, email)
      end
    end
    
    inline_element('link/reference') do
      reference_name.map do |name|
        Texier::Element.new('a', 'href' => name)
      end
    end
    
    block_element('link/reference') do
      url = e(/[^ \n]+/).map {|url| sanitize_url(url)}
      definition = url & everything_up_to(modifier | e(/$/) {[nil]})
      
      reference = e(/^/).skip & reference_name & e(/: */).skip & definition
      reference = reference.map do |name, url, content, modifier|
        add_reference(name, [url, content.strip, modifier])
      end
      
      reference.one_or_more.skip
    end
    
    def after_parse(dom)
      # Dereference references.
      traverse(dom, 'a') do |element|
        if reference = dereference(element.href)
          element.href = reference[0] if reference[0]
          element.content ||= reference[1]
          element.modify(reference[2])
        end
      end
    end

    def add_reference(name, content)
      @references[name] = content
    end
    
    private
    
    # Expression that matches reference name.
    def reference_name
      @reference_name ||= e(/\[[^\*\[\]\n]+\]/).map do |string|
        string.gsub(/^[ \[]+|[ \]]+$/, '')
      end
    end
    
    def dereference(name)
      @references[name]
    end
    
    # Traverse the dom, passing each element to the block, one at a time.
    #
    # TODO: move this to class Texier::Module
    def traverse(element, tag_name, &block)
      case element
      when Array
        element.each {|item| traverse(item, tag_name, &block)}
      when Texier::Element
        traverse(element.content, tag_name, &block)
        block.call(element) if element.name == tag_name
      end
    end
  end
end