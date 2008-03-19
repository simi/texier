module Texier
  # This class is used to generate html output from the document object model of
  # the input document.
  class Renderer
    def initialize
      
    end
    
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
    
    protected
    
    def render_attributes(attributes)
      # TODO: sanitize attribute values.
      attributes.inject('') do |output, (name, value)|
        "#{output} #{name}=\"#{value}\""
      end
    end
  end
end
