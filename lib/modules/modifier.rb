require "#{File.dirname(__FILE__)}/../module"

module Texier::Modules
  # TODO: describe various modifiers
  class Modifier < Texier::Module
    # Modifier that does nothing.
    Empty = proc {|element| element}
    
    def initialize_parser(parser)
      # .(hello world)
      title_modifier = quoted_text('(', ')').map do |value|
        proc do |element|
          # TODO: if it is <img> (and possibly some other), use alt instead of
          # title.
          element[:title] = value
          element
        end
      end


      
      # .[class #id]
      class_value = e(/\#?[a-zA-Z0-9_-]+/)
      classes = one_or_more(class_value).separated_by(/ */)
      
      class_modifier = (discard('[') & classes & discard(']')).map do |*classes|
        proc do |element|
          element[:class] ||= []
          classes.each do |value|
            if value[0] == ?#
              element[:id] = value[1..-1]
            else
              element[:class] << value
            end
          end
          
          element
        end
      end


      
      # .{style-name: style-value; ...}
      style_name = e(/[^: \n]+/)
      style_value = e(/[^;}\n]+/)
      style = style_name & discard(/ *: */) & style_value
      styles = one_or_more(style).separated_by(/ *; */).map(&Hash.method(:[]))
      
      style_modifier = (discard('{') & styles & discard('}')).map do |styles|
        proc do |element|
          # TODO: if style name is valid attribute name, assign attribute
          # instead
          
          element[:style] ||= {}
          element[:style].merge!(styles)
          element
        end
      end
      
      modifier = discard(/ *\./) \
        & (title_modifier | class_modifier | style_modifier)
      modifier = optional(modifier).map {|m| m || Empty}
      
      parser[:modifier] = modifier
    end
  end
end
