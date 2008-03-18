require "#{File.dirname(__FILE__)}/../module"

module Texier::Modules
    # This modules provides the most basic features of Texier processor.
    class Basic < Texier::Module
#      parser do
#        # Starting symbol / root element
#        document.is(zero_or_more(any_block_element).separated_by(/\n{2,}/))
#
#        # Block element or paragraph
#        any_block_element do |e|
#          e.is(block_element)
#          e.is(paragraph)
#        end
#        
#        paragraph.is(one_or_more(line).separated_by("\n"))
#        
#        line.is(one_or_more(any_inline_element))
#        
#        any_inline_element do |e|
#          e.is(inline_element)
#          e.is(any_character)
#        end
#      end

#      renderer do
#        rename(:paragraph, :p)
#        discard(:document)
#        discard(:line)
#        
#        on(:paragraph) do |e, h|
#          h.p(e.attributes) {render(e.content)}
#        end
#        
#        on(:figure) do |e, h|
#          h.div(:class => 'figure') do
#            h.img(:src => e.url, :width => e.width, :height => e.height)
#            h.p(e.description)
#          end
#        end
#      end
    end
end
