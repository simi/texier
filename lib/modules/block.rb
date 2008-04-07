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
  # Block module
  # 
  # This module defines various blocks in the document.
  # 
  # TODO: explain text, html, code, div
  class Block < Base
    include Texier::Expressions::HtmlElement
    include Texier::Expressions::Modifier
    
    block_element('block/text') do
      opening = e(/\/--+ *text *\n/).skip

      (opening & everything_up_to(closing)).map do |content|
        lines = content.split("\n")
        breaks = Array.new(lines.size - 1, Texier::Element.new('br'))

        # Put one line break between each two lines.
        lines.zip(breaks).flatten
      end
    end

    block_element('block/code') do
      opening = e(/\/--+ *code */).skip & e(/[^ \n\.]+/).maybe \
        & modifier.maybe & e("\n").skip

      (opening & everything_up_to(closing)).map do |language, modifier, content|
        Texier::Element.new(
          'pre', Texier::Element.new('code', content), 'class' => language
        ).modify(modifier)
      end
    end

    block_element('block/html') do
      content = nothing
      content << (html_element(dtd, content) | e(/[^<]+/) | e('<'))
      
      opening = e(/\/--+ *html *\n/).skip
      opening & content.one_or_more.up_to(closing)
    end

    block_element('block/div') do
      opening = e(/\/--+ *div */).skip & modifier.maybe & e("\n").skip
      
      (opening & document.up_to(closing)).map do |modifier, *content|
        Texier::Element.new('div', content).modify(modifier)
      end
    end
    
    # TODO: add pre, comment, texysource and default blocks.

    private

    def closing
      @closing ||= e(/\n\\--+ */).skip
    end
  end
end
