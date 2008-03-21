require "#{File.dirname(__FILE__)}/../module"

module Texier::Modules
  # This modules provides the most basic features of Texier processor.
  class Basic < Texier::Module
    def initialize_parser(parser)
      # These two elements are used to extend the Texier parser with custom 
      # expressions in modules.
      block_element_slot = empty
      inline_element_slot = empty

      # Plain text is default inline element.
      # TODO: support all unicode letters and numbers.
      plain_text = e(/[a-zA-Z0-9]+/)
      inline_element = inline_element_slot | plain_text | e(/[^\n]/)
      
      line = one_or_more(inline_element)
      
      # Paragraph is default block element.
      paragraph = one_or_more(line).separated_by("\n").map do |*lines|
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
      # TODO: Normalize newlines from various platforms.

      # TODO: Convert tabs to spaces.

      # etc...
      input
    end
  end
end
