# TODO: add header comment (with name, author, licence, ...) to every file.

require 'parser'
require 'renderer'

require 'modules/basic'
require 'modules/heading'
require 'modules/modifier'
require 'modules/phrase'

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
    # Configuration of Texier syntax. If you want to disable certain feature,
    # set allowed[feature_name] to false. Features and their names are defined
    # in modules.
    attr_reader :allowed
	
    # Which HTML tags, and their corresponding attributes are allowed.
	attr_accessor :allowed_tags

    # CSS classes for align modifiers. You can specify classes for these
    # alignments: :left, :right, :center, :justify, :top, :middle, :bottom
    attr_reader :align_classes
    
    
    # Document Object Model of last parsed document. You must call method
    #   +process+ before this attribute is set.
    attr_reader :dom
    
    def initialize
      @allowed = Hash.new(true)
	  @allowed_tags = :all
      @align_classes = {}
      
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
      mod.name = default_module_name(mod)
      
      # Dynamicaly define singleton method with the name of added module, so it
      # can be accessed from outside as foo_module (this is advanced ruby
      # magic).
      method_name = "#{mod.name}_module"
      (class << self; self; end).send(:define_method, method_name) {mod}
    end
	
    # Is tag allowed? Allowed tags can be specified in +allowed_tags+ property.
	def tag_allowed?(tag_name)
	  allowed_tags == :all || 
		(allowed_tags.is_a?(Hash) && !allowed_tags[tag_name].nil?)
    end
	
    # Is attribute of given tag alowed? Allowed attributes can be specified in
	# +allowed_tags+ property.
	def attribute_allowed?(tag_name, attribute_name)
	  tag_allowed?(tag_name) &&
		(allowed_tags == :all || 
		  allowed_tags[tag_name] == :all || 
		  allowed_tags[tag_name].include?(attribute_name))
    end
    
    protected
    
    def load_modules
      # These modules have to be loaded first.
      add_module Modules::Modifier.new
      add_module Modules::Basic.new

      # These modules can be loaded in any order.
      add_module Modules::Heading.new
      add_module Modules::Phrase.new
    end
    
    # Default name of module is derived from it's class name.
    def default_module_name(mod)
      name = mod.class.name
      name.sub!(/^(.*::)?/, '')
      name.downcase!
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
