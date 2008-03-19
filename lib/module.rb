require "#{File.dirname(__FILE__)}/parser"
require "#{File.dirname(__FILE__)}/element"
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
    
    # Name of the module. This is by default derived from it's class name.
    def name
      name = self.class.name # take class name
      name.sub!(/^(.*::)?/, '') # strip module names
      name.downcase!
      name += '_module'
      name.to_sym # convert to symbol
    end
  
    # This method is called before parsing. Derived classes should override it
    # if they need to preprocessing the input document.
    def before_parse(input)
      input
    end
    
    # This method is called after parsing. Derived classeas should override it
    # if they need to do something with dom tree.
    def after_parse(dom)      
    end
    
    def initialize_parser(parser)
      @parser = parser
      instance_eval(&self.class.parser_initializer)
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

    # Define parsing rules.
    def self.parser(&block)
      @parser_initializer = block
    end

    # Helper methods for generating parser rules.
    include Parser::Generators
    
    def parser
      @parser
    end
    
    # Shortcut access to block_element.
    def block_element
      parser[:block_element]
    end
    
    # Shortcut access to inline_element.
    def inline_element
      parser[:inline_element]
    end
    
    def self.parser_initializer
      @parser_initializer
    end
  end
end
