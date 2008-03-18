module Texier
  # This class is used to generate html output from the document object model of
  # the input document.
  class Renderer
    def initialize
      
    end
    
    # Render a dom element.
    def render(element)
      output = ''
      
      # Element whose name is "document" is the root element, and should be
      # ignored. This is just temporary hack, later there will be option to
      # specify ignored elements.
      
      output << "<#{element.name.to_s}>" unless element.name == :document
      
      if element.has_children?
        element.content.each do |child|
          output << render(child)
        end
      else
        output << element.content.to_s
      end
      
      output << "</#{element.name.to_s}>" unless element.name == :document
      
      output
    end
  end
end
