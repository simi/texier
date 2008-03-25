require "#{File.dirname(__FILE__)}/../module"

module Texier::Modules
  # This module defines inline phrase elements, like emphases or simple links.
  class Phrase < Texier::Module
    # Are links allowed?
    options :links_allowed => true
    
    # Shortcut for defining parsing expression for simple phrases.
    def self.simple_phrase(name, mark, tags)
      inline_element(name) {build_simple_phrase(mark, tags)}
    end

    simple_phrase('em', '*', :em)
    simple_phrase('em-alt', '//', :em)
    simple_phrase('strong', '**', :strong)
    simple_phrase('strong+em', '***', [:strong, :em])
    simple_phrase('code', '`', :code)
    simple_phrase('ins', '++', :ins)
    simple_phrase('del', '--', :del)
    simple_phrase('sup', '^^', :sup)
    simple_phrase('sub', '__', :sub)
    simple_phrase('cite', '~~', :cite)

    # Quote
    inline_element('quote') do
      quote = discard('>>') & everything_up_to(optional(modifier) & discard('<<')) & optional(link)
      quote = quote.map do |content, modifier, url|
        Texier::Element.new(:q, content, :cite => url).modify!(modifier)
      end
    end
    
    # Alternative syntax for subscripts and superscripts
    def self.subscript_or_superscript(name, mark, tag)
      inline_element(name) do
        (e(/[a-z0-9]/) & e(mark) & e(/-?\d+(?!\w)/)).map do |a, _, b|
          [a, Texier::Element.new(tag, b)]
        end
      end
    end

    subscript_or_superscript('sup-alt', '^', :sup)
    subscript_or_superscript('sub-alt', '_', :sub)

    # Acronym/abbreviation
    inline_element('acronym') do
      content = e(/\w{2,}|(\"[^\"\n]+\")/).map {|s| s.gsub(/^\"|\"$/, '')}
      
      (content & quoted_text('((', '))')).map do |acronym, meaning|
        Texier::Element.new(:acronym, acronym, :title => meaning)
      end
    end
    
    # Span
    def self.span(name, mark)
      inline_element(name) do
        mark = discard(mark)
        
        # Span with link and optional modifier.
        span_with_link = mark & everything_up_to(optional(modifier) & mark) & link
        span_with_link = span_with_link.map do |text, modifier, url|
          element = Texier::Element.new(:a, text, :href => url)
          element.modify!(modifier)
        end
      
        # Span with modifier.
        span_with_modifier = mark & everything_up_to(modifier & mark)
        span_with_modifier = span_with_modifier.map do |text, modifier|
          Texier::Element.new(:span, text).modify!(modifier)
        end
      
        span_with_link | span_with_modifier
      end
    end
    
    span('span', '"')
    span('span-alt', '~')
    
    # Quick links (blah:www.metatribe.org)
    inline_element('quicklink') do
      (e(/[^\s:]+/) & link).map do |content, url|
        Texier::Element.new(:a, content, :href => url)
      end
    end
    
    inline_element('notexy') do
      quoted_text("''").map(&Texier::Utilities.method(:escape_html))
    end

    def processor=(processor)
      super
      
      # Disable these by default.
      processor.allowed['phrase/ins'] = false
      processor.allowed['phrase/del'] = false
      processor.allowed['phrase/sup'] = false
      processor.allowed['phrase/sub'] = false
      processor.allowed['phrase/cite'] = false
    end
    
    protected

    # Build expression that matches a phrase element.
    def build_simple_phrase(mark, tags)
      mark = discard(/#{Regexp.quote(mark)}(?!#{Regexp.quote(mark[0,1])})/)
      
      phrase = mark & everything_up_to(optional(modifier) & mark) & optional(link)
      phrase = phrase.map do |content, modifier, url|
        element = [*tags].reverse.inject(content) do |element, tag|
          Texier::Element.new(tag, element)
        end
        element = Texier::Element.new(:a, element, :href => url) if url
        element.modify!(modifier)
      end
    end
    
    # Expression that matches link.
    def link
      @link ||= if links_allowed?
        e(/:((\[[^\]\n]+\])|(\S*[^:);,.!?\s]))/).map do |url|
          url.gsub(/^:\[?|\]$/, '')
        end
      else
        empty
      end
    end
  end
end