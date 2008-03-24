require "#{File.dirname(__FILE__)}/../module"

module Texier::Modules
  # This modules provides the most basic features of Texier processor.
  class Basic < Texier::Module
    SPECIAL_CHARS = " \n`~!@\#$%^&*()-_=+\\|[{]};:'\",<.>/?"
    
    options :tab_width => 4
    
    def initialize_parser(parser)
      # These two elements are used to extend the Texier parser with custom 
      # expressions in modules.
      block_element_slot = empty
      inline_element_slot = empty

      plain_text = e(/[^#{Regexp.quote(SPECIAL_CHARS)}]+/)
      inline_element = inline_element_slot | plain_text | e(/[^\n]/)
      
      line = one_or_more(inline_element)
      
      # Paragraph is default block element.
      paragraph = (line & zero_or_more(e("\n") & line)).map do |*lines|
        Texier::Element.new(:p, lines)
      end
      block_element = block_element_slot | paragraph

      # Root element / starting symbol.
      document = zero_or_more(block_element).separated_by(/\n{2,}/)

      # Export these expressions, so they can be used in other modules.
      parser[:document] = document      
      parser[:block_element] = block_element
      parser[:block_element_slot] = block_element_slot      
      parser[:inline_element] = inline_element
      parser[:inline_element_slot] = inline_element_slot
    end

    def before_parse(input)
      input = input.dup
      
      # Standardize line endings to unix style.
      input.gsub!("\r\n", "\n") # DOS/Windows style
      input.gsub!("\r", "\n") # Mac style

      # Convert tabs to spaces.
      input.gsub!(/^(.*)\t/) do
        "#{$1}#{' ' * (tab_width - $1.length % tab_width)}"
      end

      input
    end
  end
end
