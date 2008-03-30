module Texier::Modules
  # TODO: describe various modifiers
  class Modifier < Texier::Module
    ALIGNS = {
      '<>' => :center,
      '<' => :left,
      '>' => :right,
      '=' => :justify
    }

    # List of properties which are regarded as HTML attributes.
    ATTRIBUTES = [
      'abbr', 'accesskey', 'align', 'alt', 'archive', 'axis', 'bgcolor',
      'cellpadding', 'cellspacing', 'char', 'charoff', 'charset', 'cite',
      'classid', 'codebase', 'codetype', 'colspan', 'compact', 'coords','data',
      'datetime', 'declare', 'dir', 'face', 'frame', 'headers', 'href',
      'hreflang', 'hspace', 'ismap', 'lang', 'longdesc', 'name', 'noshade',
      'nowrap', 'onblur', 'onclick', 'ondblclick', 'onkeydown', 'onkeypress',
      'onkeyup', 'onmousedown', 'onmousemove', 'onmouseout', 'onmouseover',
      'onmouseup', 'rel', 'rev', 'rowspan', 'rules', 'scope', 'shape', 'size',
      'span', 'src', 'standby', 'start', 'summary', 'tabindex', 'target',
      'title', 'type', 'usemap', 'valign', 'value', 'vspace'
    ].to_set

    def initialize_parser
      unless processor.allowed['modifier']
        processor.expressions[:modifier] = empty
        return
      end

      # .(hello world)
      title_modifier = quoted_text('(', ')').map do |value|
        proc do |element|
          # TODO: if it is <img> (and possibly some other), use alt instead of
          # title.

          # TODO: Apply typographic fixes (when Typography module is finished)
          element.title = value.strip
        end
      end



      # .[class #id]
      class_value = e(/\#?[a-zA-Z0-9_-]+/)
      classes = class_value.one_or_more.separated_by(/ */)

      class_modifier = (e('[').skip & classes & e(']').skip).map do |*values|
        proc do |element|
          values.each do |value|
            next unless processor.class_allowed?(value)
			
            if value[0] == ?#
              element.id = value[1..-1]
            else
              element.add_class_name(value)
            end
          end
        end
      end



      # .{style-name: style-value; ...}
      style_name = e(/[^: \n]+/)
      style_value = e(/[^;}\n]+/)
      style = style_name & e(/ *: */).skip & style_value
      styles = style.one_or_more.separated_by(/ *; */).map(&Hash.method(:[]))

      style_modifier = (e('{').skip & styles & e('}').skip).map do |values|
        proc do |element|
          values.each do |name, value|
            if ATTRIBUTES.include?(name)
              if processor.attribute_allowed?(element.name, name)
                element.attributes[name] = value 
              end
            else
              if processor.style_allowed?(name)
                element.style ||= {}
                element.style[name] = value
              end
            end
          end
        end
      end



      # .> or .< or .<> or .=
      horizontal_align_modifier = e(/<>|<|>|=/) do |value|
        proc do |element|
          align = ALIGNS[value]
          if align_class = processor.align_classes[align]
            element.add_class_name(align_class)
          elsif processor.style_allowed?('text-align')
            element.style ||= {}
            element.style['text-align'] = align.to_s
          end
        end
      end

      processor.expressions[:modifier] = e(/ *\./).skip & (
        title_modifier | class_modifier | style_modifier |
        horizontal_align_modifier
      ).one_or_more.group
    end
  end
end
