require "#{File.dirname(__FILE__)}/../module"

module Texier::Modules
  # This modules provides the most basic features of Texier processor.
  class Basic < Texier::Module
    PUNCTUATION = Regexp.escape(" \n`~!@\#$%\^&*()\-_=+\\|[{]};:'\",<.>/?")

    options :tab_width => 4

    def initialize_parser(parser)
      # These two elements are used to extend the Texier parser with custom
      # expressions in modules.
      block_element_slot = empty
      inline_element_slot = empty

      plain_text = e(/[^#{PUNCTUATION}]+/)
      inline_element = inline_element_slot | plain_text | e(/[^\n]/)

      line = one_or_more(inline_element)

      line_break = e("\n") # TODO: insert <br /> when neccessary
      first_line = line
      next_lines = zero_or_more(line_break & -block_element_slot & line)

      # Paragraph is default block element.
      paragraph = optional(parser[:modifier] & discard(/ *\n/)) \
        & discard(/ */) & first_line & next_lines
        
      paragraph = paragraph.map do |modifier, *lines|
        Texier::Element.new('p', lines).modify!(modifier)
      end

      block_element = block_element_slot | paragraph

      # Root element / starting symbol.
      document = discard(/\s*/) & zero_or_more(block_element).separated_by(/\n+/)
      
          
      # Expression that matches link.
      # 
      # TODO: this is just temporary. When Link module is finished, it will be
      # moved there.
      link = e(/:((\[[^\]\n]+\])|(\S*[^:);,.!?\s]))/).map do |url|
        url.gsub(/^:\[?|\]$/, '')
      end

      # Export these expressions, so they can be used in other modules.
      parser[:document] = document
      parser[:block_element] = block_element
      parser[:block_element_slot] = block_element_slot
      parser[:inline_element] = inline_element
      parser[:inline_element_slot] = inline_element_slot
      parser[:link] = link
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