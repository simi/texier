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

module Texier
  # This class is used to generate html output from the document object model of
  # the input document.
  class Renderer
    # Render a dom element.
    def render(element)
      case element
      when Array
        element.inject('') do |partial, item|
          partial + render(item)
        end
      when Element
        output = ''
        output << "<#{element.name.to_s}"
        output << render_attributes(element.attributes)

        if element.empty?
          output << ' />'
        else
          output << '>'
          output << render(element.content)
          output << "</#{element.name.to_s}>"
        end

        output
      else
        element.to_s
      end
    end

    def render_text(element)
      case element
      when Array
        element.inject('') do |result, element|
          result + render_text(element)
        end
      when Element
        render_text(element.content)
      else
        element.to_s
      end
    end

    protected

    def render_attributes(attributes)
      # Ignore nil, false and empty values.
      attributes = attributes.reject do |key, value|
        !value || value.empty?
      end

      attributes.inject([]) do |output, (name, value)|
        case value
        when Array
          # TODO: sanitize values
          value = value.join(' ')
        when Hash
          # TODO: sanitize names and values
          value = value.inject([]) do |value, (hash_name, hash_value)|
            value + ["#{hash_name}: #{hash_value}"]
          end.join('; ')
        else
          # Sanitize values
          value = Texier::Utilities.escape_html(value)
          value = value.gsub('"', '&quot;')
        end

        output << " #{name}=\"#{value}\""
        output
      end.sort.join
    end
  end
end
