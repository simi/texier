require 'parser'
require 'renderer'
require 'modules/basic'

module Texier
  # The main class of Texier. You process Texy files by calling method +process+
  #   on an instance of this class:
  # 
  #   p = Texier::Processor
  #   output = p.process(input)
  # 
  # There is also a shortcut, if you don't need to do anything fancy with the
  # processor:
  # 
  #   output = Texier.process(input)
  # 
  # This class also contain methods to configure Texier output or manage
  # Texier's modules.
  class Processor
    # Document Object Model of last parsed document. You must call method
    #   +process+ at least once to set this attribute.
    attr_reader :dom
    
    def initialize
      @modules = []
      
      @modules << Modules::Basic.new(self)
    end
    
    # Process input string in Texy format and produce output (by default in HTML
    #   format).
    def process(input)
      # Processing consist of 3 phases:
      # 
      # 1. preprocessing
      # 2. parsing
      # 3. rendering
      
      input = preprocess(input)
      parse(input)
      render
    end
    
    protected
    
    # Preprocessing of input document. Each module can do it's own
    # preprocessing, if neccessary. An example can be the sanitization of HTML
    # tags.
    def preprocess(input)
      @modules.inject(input) do |string, mod|
        mod.preprocess(string)
      end
    end

    # Parse the input document and create it's Document Object Model (dom).
    def parse(input)
      parser = Parser.new
       
      @modules.each do |mod|
        mod.initialize_parser(parser)
      end
       
      @dom = parser.parse(input)
    end
    
    # Traverse dom and create resulting HTML document.
    # 
    # NOTE: should i bother adding support for other output formats?
    def render
      renderer = Renderer.new
      
      renderer.render(@dom)
    end
  end
  
  # Shortcut method that creates a Texier processor and calls it's +process+
  # method.
  def self.process(input)
    Processor.new.process(input)
  end
end
