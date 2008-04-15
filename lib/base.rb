#
# Copyright (c) 2008 Adam Ciganek <adam.ciganek@gmail.com>
#
# This file is part of Texier.
#
# Texier is free software: you can redistribute it and/or modify it under the
# terms of the GNU General Public License version 2 as published by the Free
# Software Foundation.
#
# Texier is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Texier. If not, see <http://www.gnu.org/licenses/>.
#
# For more information please visit http://code.google.com/p/texier/
#

require 'set'

$: << "#{File.dirname(__FILE__)}"

require 'comment'
require 'dtd'
require 'element'
require 'error'
require 'parser'
require 'renderer/html'
require 'renderer/plain_text'
require 'utilities'

require 'modules/base'

require 'modules/block'
require 'modules/block_quote'
require 'modules/core'
require 'modules/emoticon'
require 'modules/figure'
require 'modules/heading'
require 'modules/horiz_line'
require 'modules/html'
require 'modules/image'
require 'modules/link'
require 'modules/list'
require 'modules/modifier'
require 'modules/phrase'
require 'modules/table'



module Texier
  # The main class of Texier. You process Texy files by calling method +process+
  #   on an instance of this class:
  #
  #   p = Texier::Base
  #   output = p.process(input)
  #
  # There is also a shortcut, if you don't need to do anything fancy with the
  # processor:
  #
  #   output = Texier.process(input)
  #
  # This class also contain methods to configure Texier output or manage
  # Texier's modules.
  class Base
    # Configuration of Texier syntax. If you want to disable certain feature,
    # set allowed[feature_name] to false. Features and their names are defined
    # in modules.
    attr_reader :allowed

    # Which HTML tags or their corresponding attributes are allowed.
    attr_accessor :allowed_tags

    # Which CSS classes and id's are allowed.
    attr_accessor :allowed_classes

    # Which inline CSS styles are allowed?
    attr_accessor :allowed_styles

    # CSS classes for align modifiers. You can specify classes for these
    # alignments: :left, :right, :center, :justify, :top, :middle, :bottom
    attr_accessor :align_classes


    # Document Object Model of last parsed document. You must call method
    #   +process+ before this attribute is set.
    attr_reader :dom


    # Exported parsing expressions.
    attr_reader :expressions

    # DTD of output document.
    attr_accessor :dtd

    def initialize
      @allowed = Hash.new(true)
      @allowed_tags = :all
      @allowed_classes = :all
      @allowed_styles = :all
      @align_classes = {}

      @dtd = Dtd.new

      @expressions = {}

      install Modules::Modifier.new
      install Modules::Core.new
      install Modules::Link.new

      install Modules::Block.new
      install Modules::BlockQuote.new
      install Modules::Emoticon.new
      install Modules::Heading.new
      install Modules::HorizLine.new
      install Modules::Html.new

      install Modules::Image.new
      install Modules::Figure.new

      install Modules::List.new
      install Modules::Phrase.new
      install Modules::Table.new
    end

    # Process input string in Texy format and produce output in HTML format.
    def process(input)
      initialize_parser
      input = before_parse(input)
      parse(input)
      after_parse
      render
    end

    # Install a module.
    def install(mod)
      @modules ||= []
      @modules << mod

      @named_modules ||= {}
      @named_modules["#{module_name(mod)}_module".to_sym] = mod

      # TODO: rename processor to something nicer and shorter
      mod.processor = self
    end

    # TODO: uninstall

    # Is tag allowed? Allowed tags can be specified in +allowed_tags+ property.
    def tag_allowed?(tag_name)
      allowed_tags == :all ||
        (allowed_tags.is_a?(Hash) && !allowed_tags[tag_name].nil?)
    end

    # Is attribute of given tag alowed? Allowed attributes can be specified in
    # +allowed_tags+ property.
    def attribute_allowed?(tag_name, attribute_name)
      # TODO: take also current dtd into consideration.

      tag_allowed?(tag_name) &&
        (allowed_tags == :all ||
          allowed_tags[tag_name] == :all ||
          allowed_tags[tag_name].include?(attribute_name))
    end

    # Is class allowed?
    def class_allowed?(class_name)
      allowed_classes == :all ||
        (allowed_classes.is_a?(Array) && allowed_classes.include?(class_name))
    end

    # Is style allowed?
    def style_allowed?(style_name)
      allowed_styles == :all ||
        (allowed_styles.is_a?(Array) && allowed_styles.include?(style_name))
    end

    protected

    # Access modules using methods.
    def method_missing(name, *args, &block)
      @named_modules[name] || super
    end

    # Name of module, derived from it's class.
    def module_name(mod)
      name = mod.class.name
      name.gsub!(/^.*::/, '')
      name.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      name.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
      name.downcase!
      name
    end

    def initialize_parser
      @expressions = {}
      @modules.each do |mod|
        mod.initialize_parser
      end
    end

    # This is called before parsing. Here the input document can be modified as
    # neccessary.
    def before_parse(input)
      @modules.inject(input) do |input, mod|
        mod.before_parse(input)
      end
    end

    # Parse the input document and create Document Object Model (dom).
    def parse(input)
      unless @expressions[:document]
        raise Texier::Error, 'Document expression not defined.'
      end

      @dom = @expressions[:document].parse(input)
    end

    # This is called after parsing. Here the dom tree can be traversed and
    # modified.
    def after_parse
      @modules.each do |mod|
        mod.after_parse(@dom)
      end
    end

    # Traverse dom tree and create output HTML document.
    def render
      renderer = Renderer::Html.new(@dtd)
      renderer.render(@dom)
    end
  end

  # Shortcut method that creates a Texier processor and calls it's +process+
  # method.
  def self.process(input)
    Base.new.process(input)
  end
end
