require "#{File.dirname(__FILE__)}/../module"

module Texier::Modules
    # This modules provides the most basic features of Texier processor.
    class Basic < Texier::Module
      parser do
        self.start = :document
        
        document.is zero_or_more(paragraph).separated_by(/\n{2,}/)
        
        paragraph.is one_or_more(line).separated_by("\n") do |*lines|
          Texier::Element.new(:p, lines)
        end
        
        line.is everything_up_to(/$/)
      end
    end
end
