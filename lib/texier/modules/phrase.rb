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
  # This module defines inline phrase elements, like emphases or simple links.
  class Phrase < Base
    # Unicode character for minus (codepoint U+2212)
    MINUS = "\xE2\x88\x92"
    
    # Are links allowed?
    options :links_allowed => true
    
    # Shortcut for defining parsing expression for simple phrases.
    def self.simple_phrase(name, mark, tags)
      inline_element(name) {simple_phrase(mark, tags)}
    end

    simple_phrase('phrase/em', '*', 'em')
    simple_phrase('phrase/em-alt', '//', 'em')
    simple_phrase('phrase/strong', '**', 'strong')
    simple_phrase('phrase/strong+em', '***', ['strong', 'em'])
    simple_phrase('phrase/code', '`', 'code')
    simple_phrase('phrase/ins', '++', 'ins')
    simple_phrase('phrase/del', '--', 'del')
    simple_phrase('phrase/sup', '^^', 'sup')
    simple_phrase('phrase/sub', '__', 'sub')
    simple_phrase('phrase/cite', '~~', 'cite')

    # Quote
    inline_element('phrase/quote') do
      quote = e('>>').skip & everything_up_to(modifier.maybe & e('<<').skip) & link.maybe
      quote = quote.map do |content, modifier, url|
        build('q', content, 'cite' => url).modify(modifier)
      end
    end
    
    # Alternative syntax for subscripts and superscripts
    def self.subscript_or_superscript(name, mark, tag)
      inline_element(name) do
        e(/([a-z0-9])#{Regexp.quote(mark)}(-?\d+(?!\w))/) do |a, b|
          [a, build(tag, b.gsub('-', MINUS))]
        end
      end
    end

    subscript_or_superscript('phrase/sup-alt', '^', 'sup')
    subscript_or_superscript('phrase/sub-alt', '_', 'sub')

    # Acronym/abbreviation
    inline_element('phrase/acronym') do
      content = e(/(\w{2,})|(?:\"([^\"\n]+)\")/).map {|a, b| a || b}
      
      (content & quoted_text('((', '))')).map do |acronym, meaning|
        build('acronym', acronym, 'title' => meaning)
      end
    end
    
    # Span
    def self.span(name, mark)
      inline_element(name) do
        mark = e(mark).skip
        
        # Span with link and optional modifier.
        span_with_link = mark & everything_up_to(modifier.maybe & mark) & link
        span_with_link = span_with_link.map do |text, modifier, url|
          element = base.link_module.build_link(text, url)
          element.modify(modifier)
        end
      
        # Span with modifier.
        span_with_modifier = mark & everything_up_to(modifier & mark)
        span_with_modifier = span_with_modifier.map do |text, modifier|
          build('span', text).modify(modifier)
        end
      
        span_with_link | span_with_modifier
      end
    end
    
    span('phrase/span', '"')
    span('phrase/span-alt', '~')
    
    # Quick links (blah:www.metatribe.org)
    inline_element('phrase/quicklink') do
      (e(/[^\s:]+/) & link).map do |content, url|
        base.link_module.build_link(content, url)
      end
    end
    
    inline_element('phrase/notexy') {quoted_text("''")}

    def base=(base)
      super
      
      # Disable these by default.
      base.allowed['phrase/ins'] = false
      base.allowed['phrase/del'] = false
      base.allowed['phrase/sup'] = false
      base.allowed['phrase/sub'] = false
      base.allowed['phrase/cite'] = false
    end
    
    private
    
    def link
      links_allowed? ? super : nothing
    end

    # Expression that matches a phrase element.
    def simple_phrase(mark, tags)
      mark = e(/#{Regexp.quote(mark)}(?!#{Regexp.quote(mark[0,1])})/).skip
      
      phrase = mark & everything_up_to(modifier.maybe & mark) & link.maybe
      phrase = phrase.map do |content, modifier, url|
        element = [*tags].reverse.inject(content) do |element, tag|
          build(tag, element)
        end
        element = base.link_module.build_link(element, url) if url
        element.modify(modifier)
      end
    end
  end
end