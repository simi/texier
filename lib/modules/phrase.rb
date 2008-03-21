require "#{File.dirname(__FILE__)}/../module"

module Texier::Modules
  class Phrase < Texier::Module
    inline_element('em') {build_phrase('*', :em)}
    inline_element('em-alt') {build_phrase('//', :em)}
    inline_element('strong') {build_phrase('**', :strong)}
    inline_element('strong+em') {build_phrase('***', [:strong, :em])}
    inline_element('quote') {build_phrase(['>>', '<<'], :q)}
    inline_element('code') {build_phrase('`', :code)}
    
    protected
    
    # Build expression that matches a phrase element.
    def build_phrase(marks, names)
      # Create expressions for opening and closing marks.
      marks = [*marks].map do |mark|
        expression(/#{Regexp.quote(mark)}(?!#{Regexp.quote(mark[0,1])})/)
      end      
      marks = [marks[0], marks[0]] if marks.size < 2
      
      # Create phrase expression.
      (marks[0] & everything_up_to(marks[1]) & marks[1]).map do |_, content, _|
        [*names].reverse.inject(content) do |element, name|
          Texier::Element.new(name, element)
        end
      end
    end
  end
end