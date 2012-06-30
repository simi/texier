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
  class Block < Base
    # Text block. /-- text
    # 
    # Content of this block is interpreted as plain text. No Texier elements are
    # processed and all html is escaped.
    block_element('block/text') do
      opening = e(/\/--+ *text *\n/).skip

      (opening & everything_up_to(closing)).map do |content|
        lines = content.split("\n")
        breaks = Array.new(lines.size - 1, build('br'))

        # Put one line break between each two lines.
        lines.zip(breaks).flatten
      end
    end

    # Code block. /-- code language
    # 
    # Content of this block is interpreted as source code. No Texier elements
    # are processed and formatting and indentation are left intact. The optional
    # "language" parameter can specify language of the source code. This can be
    # used to provide syntax highlighting.
    # 
    # TODO: syntax highlighting (use some external tool).
    block_element('block/code') do
      opening = e(/\/--+ *code */).skip & e(/[^ \n\.]+/).maybe \
        & modifier.maybe & e("\n").skip

      (opening & everything_up_to(closing)).map do |language, modifier, content|
        build(
          'pre', build('code', content), 'class' => language
        ).modify(modifier)
      end
    end

    # Html block. /-- html
    # 
    # Content of this block is interpreted as fragment of html document. No
    # Texier elements are processed. Html tags are left intact.
    block_element('block/html') do
      content = nothing
      html_element = base.html_module.html_element(dtd, content)
      content << (html_element | e(/[^<]+/) | e('<'))
      
      opening = e(/\/--+ *html *\n/).skip
      opening & content.one_or_more.up_to(closing)
    end

    # Div block. /-- div
    # 
    # The content of this block is interpeted as ordinary Texier document. The
    # result is enclosed in <div> ... </div> tags. It can be used to delimit the
    # document into logical sections.
    block_element('block/div') do
      opening = e(/\/--+ *div */).skip & modifier.maybe & e("\n").skip
      
      (opening & document.up_to(closing)).map do |modifier, *content|
        build('div', content).modify(modifier)
      end
    end
    
    # TODO: add pre, comment, texysource and default blocks. (but they are not
    # specified in Texy! documentation, do i realy need them?)

    private

    def closing
      @closing ||= e(/\n\\--+ */).skip
    end
  end
end
