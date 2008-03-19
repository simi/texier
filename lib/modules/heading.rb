require "#{File.dirname(__FILE__)}/../module"

module Texier::Modules
  # This module provides headings.
  class Heading < Texier::Module
    parser do
      surrounded_heading = empty
      underlined_heading = empty
      
      parser[:block_element] |= surrounded_heading
      parser[:block_element] |= underlined_heading
      
#      # Define headings with bullet
#      heading.is(
#        surrounded_heading_marker, 
#        surrounded_heading_content, 
#        surrounded_heading_tail
#      ) do |level, content, _|
#        Texier::Element.new(:"h#{level}", content)
#      end
#      
#      surrounded_heading_marker.is(/ *(\#{2,}|={2,}) +/) do |line|
#        # Calculate relative level of heading from length of the marker.
#        8 - [line.strip.length, 7].min
#      end
#      
#      surrounded_heading_content.is everything_up_to(surrounded_heading_tail)
#      surrounded_heading_tail.is(/ *(\#{2,}|={2,})? *$/)
#      
#      block_element.is heading
    end
  end
end
