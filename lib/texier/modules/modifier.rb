# 
# Copyright (c) 2008 Adam Ciganek <adam.ciganek@gmail.com>
# 
# This file is part of Texier.
# 
# Texier is free software: you can redistribute it and/or modify it under the
# terms of the GNU General Public License version 2 as published by the Free
# Software Foundation.
# 
# Texier is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along with
# Texier. If not, see <http://www.gnu.org/licenses/>.
# 
# For more information please visit http://code.google.com/p/texier/
# 

module Texier::Modules
  # This module provides modifiers. They are used to set classes, ids, titles,
  # inline styles and alignments (and many more, of course :)). Modifiers can be
  # specified for almost every Texier element.
  class Modifier < Base
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
      
    export_expression(:modifier) do
      if base.allowed['modifier']
        e(/ *\./).skip & (
          title_modifier | class_modifier | style_modifier |
          horizontal_align_modifier
        ).one_or_more.group
      else
        nothing
      end
    end
        
    private
      
    # Title attribute for element.
    # 
    # Syntax: .(hello world)
    def title_modifier
      quoted_text('(', ')').map do |value|
        proc do |element|
          # TODO: Apply typographic fixes (when Typography module is finished)
          element.title = value.strip
        end
      end
    end

    # Classes and ids.
    # 
    # Syntax: .[class #id]
    def class_modifier
      class_value = e(/\#?[a-zA-Z0-9_-]+/)
      classes = class_value.one_or_more.separated_by(/ */)

      (e('[').skip & classes & e(']').skip).map do |*values|
        proc do |element|
          values.each do |value|
            next unless base.class_allowed?(value)
			
            if value[0] == ?#
              element.id = value[1..-1]
            else
              element.add_class_name(value)
            end
          end
        end
      end
    end

    # Inline styles.
    # 
    # Syntax: .{style-name: style-value; ...}
    def style_modifier
      style_name = e(/[^: \n]+/)
      style_value = e(/[^;}\n]+/)
      style = style_name & e(/ *: */).skip & style_value
      styles = style.one_or_more.separated_by(/ *; */).map(&Hash.method(:[]))

      (e('{').skip & styles & e('}').skip).map do |values|
        proc do |element|
          values.each do |name, value|
            if ATTRIBUTES.include?(name)
              if base.attribute_allowed?(element.name, name)
                element.attributes[name] = value 
              end
            else
              if base.style_allowed?(name)
                element.style ||= {}
                element.style[name] = value
              end
            end
          end
        end
      end
    end

    # Horizontal alignments.
    # 
    # Syntax: .> or .< or .<> or .=
    def horizontal_align_modifier
      e(/<>|<|>|=/) do |value|
        proc do |element|
          align = ALIGNS[value]
          if align_class = base.align_classes[align]
            element.add_class_name(align_class)
          elsif base.style_allowed?('text-align')
            element.style ||= {}
            element.style['text-align'] = align.to_s
          end
        end
      end
    end
    
    # TODO: Vertical alignments
  end
end