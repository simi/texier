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
    
    # TODO: consecutive string children should be concatenated into one.
    
    # TODO: dom builder
    
    def name=(value)
      @name = value
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

    # Access attributes using methods:
    # 
    # element.foo = 'bar' is the same as element.attributes['foo'] = 'bar'.
    def method_missing(name, *args)
      return super unless name.to_s =~ /[a-z_]+=?/

      name = name.to_s
      if name[-1] == ?=
        @attributes[name[0..-2]] = args.first
      else
        @attributes[name]
      end
    end
	
    # This is here just to suppress warning that foo.id is deprecated.
    def id
      @attributes['id']
    end
	
    def id=(value)
      @attributes['id'] = value
    end
	
    def class_name=(value)
      @attributes['class'] = value
    end
	
    def class_name
      @attributes['class']
    end
	
    # Convenience method for adding class names.
    def add_class_name(value)
      @attributes['class'] ||= []
      @attributes['class'] << value
      self
    end
    
    # Apply modifier.
    def modify!(modifier)
      modifier.each {|m| m.call(self)} if modifier
      self
    end
  end
end
