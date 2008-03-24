require "#{File.dirname(__FILE__)}/../module"

module Texier::Modules
  class Phrase < Texier::Module
    # Shortcut for defining parsing expression for simple phrases.
    def self.simple_phrase(name, marks, tags)
      inline_element(name) {build_simple_phrase(marks, tags)}
    end

    simple_phrase('em', '*', :em)
    simple_phrase('em-alt', '//', :em)
    simple_phrase('strong', '**', :strong)
    simple_phrase('strong+em', '***', [:strong, :em])
    simple_phrase('quote', ['>>', '<<'], :q) # TODO: support "cite" links
    simple_phrase('code', '`', :code)
    simple_phrase('ins', '++', :ins)
    simple_phrase('del', '--', :del)
    simple_phrase('sup', '^^', :sup)
    simple_phrase('sub', '__', :sub)
    simple_phrase('cite', '~~', :cite)

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
      
      acronym = content & e('((') & everything_up_to('))') & e('))')
      acronym = acronym.map do |acronym, _, meaning, _|
        Texier::Element.new(:acronym, acronym, :title => meaning)
      end
    end
    
    # Span
    inline_element('span') do
      (e('"') & everything_up_to('"') & e('"') & link).map do |_, text, _, url|
        Texier::Element.new(:a, text, :href => url)
      end
    end
    
    inline_element('span-alt') do
      (e('~') & everything_up_to('~') & e('~') & link).map do |_, text, _, url|
        Texier::Element.new(:a, text, :href => url)
      end
    end

    # Quick links (blah:www.metatribe.org)
    inline_element('quicklink') do
      (e(/[^\s:]+/) & link).map do |content, url|
        Texier::Element.new(:a, content, :href => url)
      end
    end
    
    inline_element('notexy') do
      (e("''") & everything_up_to("''") & e("''")).map do |_, text, _| 
        Texier::Utilities.escape_html(text)
      end
    end
    
    protected

    # Build expression that matches a phrase element.
    def build_simple_phrase(marks, tags)
      # Expressions for opening and closing marks.
      marks = [*marks].map do |mark|
        e(/#{Regexp.quote(mark)}(?!#{Regexp.quote(mark[0,1])})/)
      end
      marks = [marks[0], marks[0]] if marks.size < 2

      # Phrase expression.
      phrase = marks[0] & everything_up_to(modifier & marks[1]) & modifier & marks[1] & optional(link)
      phrase = phrase.map do |_, content, modifier, _, url|
        element = [*tags].reverse.inject(content) do |element, tag|
          Texier::Element.new(tag, element)
        end
        element = Texier::Element.new(:a, element, :href => url) if url
        modifier.call(element)
      end
    end
    
    # Expression that matches link.
    def link
      @link ||= e(/:(\[[^\]\n]+\])|(\S*[^:);,.!?\s])/).map do |url|
        url.gsub(/^:\[?|\]$/, '')
      end
    end
  end
end