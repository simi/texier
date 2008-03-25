require "#{File.dirname(__FILE__)}/../module"

module Texier::Modules
  # TODO: describe various modifiers
  class Modifier < Texier::Module
    def initialize_parser(parser)
      # .(hello world)
      title_modifier = quoted_text('(', ')').map do |value|
        proc do |element|
          # TODO: if it is <img> (and possibly some other), use alt instead of
          # title.
          element[:title] = value.strip
        end
      end


      
      # .[class #id]
      class_value = e(/\#?[a-zA-Z0-9_-]+/)
      classes = one_or_more(class_value).separated_by(/ */)
      
      class_modifier = (discard('[') & classes & discard(']')).map do |*values|
        proc do |element|
          element[:class] ||= []
          values.each do |value|
            if value[0] == ?#
              element[:id] = value[1..-1]
            else
              element[:class] << value
            end
          end
        end
      end


      
      # .{style-name: style-value; ...}
      style_name = e(/[^: \n]+/)
      style_value = e(/[^;}\n]+/)
      style = style_name & discard(/ *: */) & style_value
      styles = one_or_more(style).separated_by(/ *; */).map(&Hash.method(:[]))
      
      style_modifier = (discard('{') & styles & discard('}')).map do |values|
        proc do |element|
          # TODO: if style name is valid attribute name, assign attribute
          # instead
          
          element[:style] ||= {}
          element[:style].merge!(values)
        end
      end
      
      parser[:modifier] = discard(/ *\./) \
        & one_or_more(title_modifier | class_modifier | style_modifier).group
    end
  end
end
