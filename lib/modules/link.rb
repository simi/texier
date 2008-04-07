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
    include Texier::Expressions::Modifier
    
    # TODO: obfuscate emails, shorten urls, ...
    
    def initialize
      @references = {}
    end
    
    def before_parse(input)
      # Collect reference defintions.
      
      return input unless processor.allowed['link/definition']
      
      url = e(/[^ \n]+/)
      content = e(/ */).skip & inline_element.zero_or_more.group
      value = url & content.up_to(modifier | e(/$/).skip)
      
      definition = e(/^/).skip & reference_name & e(/: */).skip & value
      definition = definition.map do |name, url, content, modifier|
        element = Texier::Element.new('a', content, 'href' => sanitize_url(url))
        element.content = url if element.content.empty?
        element.modify(modifier)
        
        add_reference(name, element)
      end
      
      line = definition.skip | e(/^[^\n]*$/)
      
      document = line.zero_or_more.separated_by("\n")
      document.parse(input).join("\n")
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
      reference_name.map {|name| dereference(name)}
    end
    
    def add_reference(name, content)
      @references[name] = content
    end
    
    def dereference(name)
      @references[name]
    end
    
    private
    
    # Expression that matches reference name.
    def reference_name
      @reference_name ||= e(/\[[^\*\[\]\n]+\]/).map do |string|
        string.gsub(/^[ \[]+|[ \]]+$/, '')
      end
    end
  end
end