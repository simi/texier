##########################################################################################
#
# Texier is a ruby port of Texy! - universal text to html converter by David Grudl (dgx).
#
# == Author
#
# rane <rane@metatribe.org>
#
# == Copyright
#
# Original version:
#   Copyright (c) 2004-2006 David Grudl
#
# Ruby port:
#   Copyright (c) 2006 rane
#
# Texier is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License version 2 as published by the Free Software
# Foundation.
#
# Texier is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# == Version
#
#  0.1 ($Revision$ $Date$)
#
##########################################################################################

$KCODE = 'u'

$:.unshift(File.dirname(__FILE__) + '/texy')

# require_once TEXY_DIR.'libs/url.php';            // object encapsulate of URL


require File.dirname(__FILE__) + '/core_extensions'
require 'constants'
require 'dom'
require 'html'
require 'html_well_form'
require 'modifier'
require 'parser'
require 'url'

require 'modules/base'
require 'modules/block'
require 'modules/definition_list'
require 'modules/formatter'
require 'modules/generic_block'
require 'modules/heading'
require 'modules/horiz_line'
require 'modules/html'
require 'modules/image'
require 'modules/image_desc'
require 'modules/link'
require 'modules/list'
# require 'modules/long_words'
require 'modules/phrase'
require 'modules/quick_correct'
require 'modules/quote'
require 'modules/script'
require 'modules/smilies'
require 'modules/table'



# Texy! - Convert plain text to XHTML format using #process
#
#   texy = Texy.new
#   html = texy.process text
#
class Texy
    # TAB width (for converting tabs to spaces)
    attr_accessor :tab_width

    # Allowed classes
    attr_accessor :allowed_classes

    # Allowed inline CSS styles
    attr_accessor :allowed_styles

    # Allowed HTML tags
    attr_accessor :allowed_tags

    # Do obfuscate e-mail addresses?
    attr_writer :obfuscate_email
    def obfuscate_email?
        @obfuscate_email
    end

    # DOM structure for parsed text
    attr_reader :dom

    # Parsing summary
    attr_accessor :summary

    # Merge lines mode
    attr_accessor :merge_lines

    attr_accessor :reference_handler

    def initialize
        self.tab_width = 8
        self.allowed_classes = :all
        self.allowed_styles = :all
        self.allowed_tags = Texy::Html::VALID # full support for HTML tags
        self.obfuscate_email = true
        self.summary = {
            :images => [],
            :links => [],
            :preload => []
        }
        self.merge_lines = true

        @line_patterns = []
        @block_patterns = []

        @references = {}

        # load all modules
        load_modules
    end

    # Covert Texy! document into (X)HTML code.
    def process(source, single_line = false)
        if single_line
            parse_line(source)
        else
            parse(source)
        end

        dom.to_html
    end

    # Convert Texy! document into internal DOM structure.
    #
    # Before converting it normalizes text and calls all pre-processing modules.
    def parse(source)
        # initialization
        init

        # process
        @dom = Texy::Dom.new(self)
        @dom.parse(source)
    end



    # List of all used modules
    attr_reader :modules

    def register_module(mod)
        @modules ||= []
        @modules << mod
    end

    # Default modules
    attr_reader(
        :block_module,
        :definition_list_module,
        :formatter_module,
        :generic_block_module,
        :heading_module,
        :horiz_line_module,
        :html_module,
        :image_module,
        :image_desc_module,
        :link_module,
        :list_module,
#        :long_words_module,
        :phrase_module,
        :quick_correct_module,
        :quote_module,
        :script_module,
        :smilies_module,
        :table_module
    )

    # Create array of all used modules.
    #
    # This array can be changed by overriding this method (by subclasses) or directly in main code.
    def load_modules
        # Line parsing - order does not matter
        @script_module = Modules::Script.new(self)
        @html_module = Modules::Html.new(self)
        @image_module = Modules::Image.new(self)
        @link_module = Modules::Link.new(self)
        @phrase_module = Modules::Phrase.new(self)
        @smilies_module = Modules::Smilies.new(self)

        # Block parsing - order does not matter
        @block_module = Modules::Block.new(self)
        @heading_module = Modules::Heading.new(self)
        @horiz_line_module = Modules::HorizLine.new(self)
        @quote_module = Modules::Quote.new(self)
        @list_module = Modules::List.new(self)
        @definition_list_module = Modules::DefinitionList.new(self)
        @table_module = Modules::Table.new(self)
        @image_desc_module = Modules::ImageDesc.new(self)
        @generic_block_module = Modules::GenericBlock.new(self)

        # post process
        @quick_correct_module = Modules::QuickCorrect.new(self)
#        @long_words_module = Modules::LongWords.new(self)
        @formatter_module = Modules::Formatter.new(self)
    end
    protected :load_modules



    # Registered regexps and associated handlers for inline parsing.
    #
    # Format:
    #   {:handler => proc,
    #    :pattern => regular expression}
    attr_reader :line_patterns

    def register_line_pattern(handler, pattern)
        @line_patterns << {
            :handler => handler,
            :pattern => pattern
        }
    end

    # Registered regexps and associated handlers for block parsing.
    #
    # Format:
    #   {:handler => proc,
    #    :pattern => regular expression}
    attr_reader :block_patterns

    def register_block_pattern(handler, pattern)
        # raise ArgumentError, 'Not a block pattern: ' + pattern.source unless /(.)\^.*\$\\1[a-z]*/i =~ pattern

        @block_patterns << {
            :handler => handler,
            :pattern => pattern
        }
    end



    # Initialization
    #
    # It is called between constructor and first use (method parse).
    def init
        @cache = []
        @line_patterns = []
        @block_patterns = []

        raise RuntimeError, 'Texy: No modules installed' if modules.empty?

        # init modules
        modules.map &:init
    end
    protected :init



    # Switch Texy and default modules to safe mode
    #
    # Suitable for "comments" and other usages, where attacker may insert input text.
    def safe_mode
        self.allowed_classes = false # no class or ID are allowed
        self.allowed_styles = false # style modifiers are disabled
        html_module.safe_mode # only HTML tags and attributes specified in $safeTags array are allowed
        image_module.allowed = false # disable images
        link_module.force_no_follow = true # force rel="nofollow"
    end



    # Switch Texy and default modules to (default) trust mode
    def trust_mode
        self.allowed_classes = :all # classes and id are allowed
        self.allowed_styles = :all # inline styles are allowed
        html_module.trust_mode # full support for HTML tags
        image_module.allowed = true # enable images
        link_module.force_no_follow = true # disable automatic rel="nofollow"
    end



    # Translate all white spaces (\t \n \r space) to meta-spaces \x15-\x18
    # which are ignored by some formatting functions
    def self.freeze_spaces(string)
        string.tr(" \t\r\n", "\x15\x16\x17\x18")
    end

    # Revert meta-spaces back to normal spaces
    def self.unfreeze_spaces(string)
        string.tr("\x15\x16\x17\x18", " \t\r\n")
    end

    # Remove special controls chars used by Texy!
    def self.wash(text)
        text.gsub(/[\x15-\x1F]+/, '')
    end

    def self.hash_opening?(hash)
        hash[1].chr == "\x1F"
    end



    # Add new named reference
    def add_reference(name, obj)
        name.downcase! # watch out for utf8!
        @references[name] = obj
    end

    # Receive new named link. If not exists, try call user function to create one.
    def reference(name)
        low_name = name.downcase # watch out for UTF8 !


        return @references[low_name] if @references[low_name]
        return reference_handler.call(name, self) if reference_handler

        false
    end



    def notice_shown=(b)
        @notice_shown = b
    end

    def notice_shown?
        @notice_shown ||= false
        @notice_shown
    end
end


# Command line usage.
if $0 == __FILE__
    texy = Texy.new
    texy.formatter_module.line_wrap = 0

    puts texy.process($ARGV[0] ? File.read($ARGV[0]) : $stdin.read)
end