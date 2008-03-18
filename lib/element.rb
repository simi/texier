module Texier
  # Element of the Document Object Model.
  class Element
    attr_reader :name
    attr_accessor :content
    
    def initialize(name = nil, content = nil)
      @name = name
      @content = content
    end
    
    # Append child element.
    def << (element)
      @content ||= []
      @content << element
    end
    
    # Has this element any children elements?
    def has_children?
      content.is_a?(Array) && content.size > 0
    end
  end
end
