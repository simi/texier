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
        output << '>'
        output << render(element.content)
        output << "</#{element.name.to_s}>"
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
        !value || value.to_s.empty?
      end
      
      attributes.inject('') do |output, (name, value)|
        # Sanitize values
        value = Texier::Utilities.escape_html(value)
        value = value.gsub('"', '&quot;')
        
        "#{output} #{name}=\"#{value}\""
      end
    end
  end
end
