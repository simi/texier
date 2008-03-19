require "#{File.dirname(__FILE__)}/parser"
require "#{File.dirname(__FILE__)}/element"

module Texier
  # The features of Texier processor are separated into self-contained modules.
  # These modules can then be added to/removed from Texier processor according
  # to what features are needed. It is also very easy to extend Texier's
  # functionality by writing your own module.
  # 
  # This is the base class for all Texier modules.
  class Module
    def initialize(processor)
      @processor = processor
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
  
    # Call this class method on derived classes to define parsing rules.
    def self.parser(&block)
      @parser_initializer = block
    end
    
    protected

    # Helper methods for generating parser rules.
    include Parser::Generators
    
    def parser
      @parser
    end
    
    def self.parser_initializer
      @parser_initializer
    end
  end
end
