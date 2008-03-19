require "#{File.dirname(__FILE__)}/../module"

module Texier::Modules
  # This modules provides the most basic features of Texier processor.
  class Basic < Texier::Module
    parser do
      block_element = Texier::Parser::Expressions::ChoiceWithDefault.new
      inline_element = Texier::Parser::Expressions::ChoiceWithDefault.new

      # One line.
      line = everything_up_to(/$/)
        
      # Paragraph is default block element.
      paragraph = one_or_more(line).separated_by("\n").map do |*lines|
        Texier::Element.new(:p, lines)
      end
      
      block_element << paragraph
        
      # Root element / starting symbol.
      document = zero_or_more(block_element).separated_by(/\n{2,}/)
        
      # Export these expressions.
      parser[:document] = document
      parser[:block_element] = block_element
      parser[:inline_element] = inline_element
    end
      
    def before_parse(input)
      # TODO: Normalize newlines from various platforms.
        
      # TODO: Convert tabs to spaces.
        
      # etc...
      input
    end
  end
end
