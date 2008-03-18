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
        "<#{element.name.to_s}>#{render(element.content)}</#{element.name.to_s}>"
      else
        element.to_s
      end
    end
  end
end
