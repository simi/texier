require "#{File.dirname(__FILE__)}/element"
require "#{File.dirname(__FILE__)}/parser"
require "#{File.dirname(__FILE__)}/utilities"

module Texier
  # The features of Texier processor are separated into self-contained modules.
  # These modules can then be added to/removed from Texier processor according
  # to what features are needed. It is also very easy to extend Texier's
  # functionality by writing your own module.
  # 
  # This is the base class for all Texier modules.
  class Module
    attr_accessor :processor
    
    # This method is called before parsing. Derived classes should override it
    # if they need to preprocess the input document.
    def before_parse(input)
      input
    end
    
    # This method is called after parsing. Derived classeas should override it
    # if they need to do something with dom tree.
    def after_parse(dom)      
    end
    
    def initialize_parser(parser)
      @parser = parser
      parser_initializers.each do |type, blocks|
        blocks.each do |block|
          parser[:"#{type}_slot"] << instance_eval(&block)
        end
      end
      @parser = nil
    end
  
    protected
    
    # Define module options. Options are defined as hash, where key is the names
    # of the option and value is it's default value.
    def self.options(hash)
      hash.each do |name, default_value|
        attr_writer name
        define_method(name) do
          if instance_variable_defined?("@#{name}")
            instance_variable_get("@#{name}")
          else
            default_value
          end
        end
      end
    end
    
    @@parser_initializers = {}
    
    def self.define_element(type, &block)
      @@parser_initializers[self] ||= {}
      @@parser_initializers[self][type] ||= []
      @@parser_initializers[self][type] << block
    end
    
    # Define new inline element.
    def self.inline_element(name, &block)
      define_element(:inline_element, &block)
    end
    
    # Define new block element.
    def self.block_element(name, &block)
      define_element(:block_element, &block)
    end
    
    def parser_initializers
      @@parser_initializers[self.class]
    end

    
    
    # Helper methods for generating parser rules.
    include Parser::Generators
    
    # Access exported parser expressions as ordinary methods.
    def method_missing(name, *args, &block)
      super unless @parser && @parser.has_expression?(name)
      @parser[name]
    end
  end
end
