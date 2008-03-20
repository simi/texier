require 'parser'
require 'renderer'

require 'modules/basic'
require 'modules/heading'

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
      load_modules
    end
    
    # Process input string in Texy format and produce output in HTML format.
    def process(input)
      input = before_parse(input)
      parse(input)
      after_parse
      render
    end
    
    def add_module(mod)
      @modules ||= []
      @modules << mod
      
      mod.processor = self
      name = default_module_name(mod)
      
      # Dynamicaly define singleton method with the name of added module, so it
      # can be accessed from outside as foo_module (this is advanced ruby
      # magic).
      (class << self; self; end).send(:define_method, name) {mod}
    end
    
    protected
    
    def load_modules      
      add_module Modules::Basic.new
      add_module Modules::Heading.new
    end
    
    def default_module_name(mod)
      name = mod.class.name
      name.sub!(/^(.*::)?/, '')
      name.downcase!
      name += '_module'
      name.to_sym
    end
    
    # This is called before parsing. Here the input document can be modified as
    # neccessary.
    def before_parse(input)
      @modules.inject(input) do |string, mod|
        mod.before_parse(string)
      end
    end

    # Parse the input document and create Document Object Model (dom).
    def parse(input)
      parser = Parser.new
       
      @modules.each do |mod|
        mod.initialize_parser(parser)
      end
       
      @dom = parser.parse(input)
    end
    
    # This is called after parsing. Here the dom tree can be traversed and
    # modified.
    def after_parse
      @modules.each do |mod|
        mod.after_parse(@dom)
      end
    end
    
    # Traverse dom tree and create output HTML document.
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
