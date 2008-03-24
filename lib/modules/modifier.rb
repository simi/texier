require "#{File.dirname(__FILE__)}/../module"

module Texier::Modules
  class Modifier < Texier::Module
    # Modifier that does nothing.
    Empty = proc {|element| element}
    
    def initialize_parser(parser)
      title = (e('(') & everything_up_to(')') & e(')')).map do |_, text, _|
        proc do |element|
          element[:title] = text
          element
        end
      end
      
      modifier = discard(/ *\./) & title
      modifier = optional(modifier).map {|m| m || Empty}
      
      parser[:modifier] = modifier
    end
  end
end
