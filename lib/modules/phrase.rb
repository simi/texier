require "#{File.dirname(__FILE__)}/../module"

module Texier::Modules
  class Phrase < Texier::Module
    inline_element('em') {build_phrase('*', :em)}
    inline_element('em-alt') {build_phrase('//', :em)}
    inline_element('strong') {build_phrase('**', :strong)}
    inline_element('strong+em') {build_phrase('***', [:strong, :em])}
    # TODO: inline_element('quote') {build_phrase(['>>', '<<'], :q)}
    
    protected
    
    def build_phrase(marker, names)
      char = marker[0,1]
      marker = expression(/#{Regexp.quote(marker)}(?!#{Regexp.quote(char)})/)
      
      (marker & everything_up_to(marker) & marker).map do |_, content, _|
        [*names].reverse.inject(content) do |element, name|
          Texier::Element.new(name, element)
        end
      end
    end
  end
end