require "#{File.dirname(__FILE__)}/../module"

module Texier::Modules
  # TODO: describe various modifiers
  class Modifier < Texier::Module
    # Modifier that does nothing.
    Empty = proc {|element| element}
    
    def initialize_parser(parser)
      # .(hello world)
      title_modifier = (e('(') & everything_up_to(')') & e(')')).map do |_, value, _|
        proc do |element|
          # TODO: if it is <img> (and possibly some other), use alt instead of
          # title.
          element[:title] = value
          element
        end
      end
      
      # .[class #id]
      class_modifier = (e('[') & everything_up_to(']') & e(']')).map do |_, values, _|
        proc do |element|
          classes = []
          values.split(/ +/).each do |value|
            if value[0] == ?#
              element[:id] = value[1..-1]
            else
              classes << value
            end
          end
          
          element[:class] = classes.join(' ')
          element
        end
      end
      
      modifier = discard(/ *\./) & (title_modifier | class_modifier)
      modifier = optional(modifier).map {|m| m || Empty}
      
      parser[:modifier] = modifier
    end
  end
end
