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

module Texier::Modules
  # Basic module.
  # 
  # This modules provides the most basic features of Texier processor. It
  # exports two parsing expressions: +inline_element+ and +block_element+. They
  # are provided for other modules to extend Texier syntax with their own
  # expressions (see documentation of class Module for explanation how to do
  # that). It also defines default inline element (plain text without any
  # formatting) and block_element (paragraph). Last, it defines expression
  # +document+ which is root expression of whole Texier grammar and coresponds
  # to whole document.
  class Basic < Texier::Module
    PUNCTUATION = Regexp.escape(" \n`~!@\#$%\^&*()\-_=+\\|[{]};:'\",<.>/?")

    # Texier converts tabs to spaces. This specifies how may spaces is one tab.
    options :tab_width => 4

    def initialize_parser
      # These two elements are used to extend the Texier parser with custom
      # expressions in modules.
      block_element_slot = nothing
      inline_element_slot = nothing

      plain_text = e(/[^#{PUNCTUATION}]+/)
      inline_element = inline_element_slot | plain_text | e(/[^\n]/)

      line = inline_element.one_or_more

      line_break = e("\n") # TODO: insert <br /> when neccessary
      first_line = line
      next_lines = (line_break & -block_element_slot & line).zero_or_more

      # Paragraph is default block element.
      paragraph = (modifier & e(/ *\n/).skip).maybe \
        & e(/ */).skip & first_line & next_lines
        
      paragraph = paragraph.map do |modifier, *lines|
        Texier::Element.new('p', lines).modify(modifier)
      end

      block_element = block_element_slot | paragraph

      # Root element / starting symbol.
      document = e(/\s*/).skip & block_element.zero_or_more.separated_by(/\n+/)
      
          
      # Expression that matches link.
      # 
      # TODO: this is just temporary. When Link module is finished, it will be
      # moved there.
      link = e(/:((\[[^\]\n]+\])|(\S*[^:);,.!?\s]))/).map do |url|
        url.gsub(/^:\[?|\]$/, '')
      end

      # Export these expressions, so they can be used in other modules.
      processor.expressions.merge!(
        :document => document,
        :block_element => block_element,
        :block_element_slot => block_element_slot,
        :inline_element => inline_element,
        :inline_element_slot => inline_element_slot,
        :link => link
      )
    end

    def before_parse(input)
      input = input.dup

      # Convert line endings to unix style.
      input.gsub!("\r\n", "\n") # DOS/Windows style
      input.gsub!("\r", "\n") # Mac style

      # Convert tabs to spaces.
      input.gsub!(/^(.*)\t/) do
        "#{$1}#{' ' * (tab_width - $1.length % tab_width)}"
      end

      input
    end
  end
end