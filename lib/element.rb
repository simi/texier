module Texier
  # Element of the Document Object Model.
  class Element
    attr_reader :name
    attr_reader :content
    attr_reader :attributes

    def initialize(name = nil, content_or_attributes = nil, attributes = {})
      self.name = name

      if content_or_attributes.is_a?(Hash)
        @attributes = content_or_attributes
      else
        self.content = content_or_attributes
        @attributes = attributes
      end
    end
    
    # TODO: create two accessors: children and text. Children will return
    # array of children, if this element has children. Text will return
    # textual content.
    
    # TODO: consecutive string children should be concatenated into one.
    
    # TODO: attributes as dynamic methods.
    
    # TODO: dom builder
    
    def name=(value)
      @name = value.to_sym
    end
    
    def content=(value)
      if value.is_a?(Array) && value.all? {|item| item.is_a?(String)}
        value = value.join
      end
      
      @content = value
    end

    # Append child element.
    def << (child)
      @content = [*@content].compact
      @content << child
      self
    end

    # Has this element any children elements?
    def has_children?
      content.is_a?(Array) && content.size > 0
    end

    # Access attribute.
    def [](name)
      @attributes[name]
    end

    # Assign attribute. If nil is assigned, attribute is deleted.
    def []=(name, value)
      if value.nil?
        @attributes.delete(name)
      else
        @attributes[name] = value
      end
    end
    
    # Apply modifier.
    def modify!(modifier)
      modifier.each {|m| m.call(self)} if modifier
      self
    end
  end
end
