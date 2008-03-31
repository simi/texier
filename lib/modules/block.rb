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
  class Block < Texier::Module
    block_element('text') do
      opening = e(/\/--+ *text *\n/).skip

      (opening & everything.up_to(closing)).map do |content|
        content = Texier::Utilities.escape_html(content)
        lines = content.split("\n")
        breaks = Array.new(lines.size - 1, Texier::Element.new('br'))

        # Put one line break between each two lines.
        lines.zip(breaks).flatten
      end
    end

    block_element('code') do
      opening = e(/\/--+ *code */).skip & e(/[^ \n]+/).maybe & e(/ *\n/).skip

      (opening & everything.up_to(closing)).map do |language, content|
        Texier::Element.new(
          'pre', Texier::Element.new('code', content), 'class' => language
        )
      end
    end

    block_element('html') do
      # TODO: fix broken html
      opening = e(/\/--+ *html *\n/).skip
      opening & everything.up_to(closing)
    end

    block_element('div') do
      opening = e(/\/--+ *div *\n/).skip
     
      (opening & document.up_to(closing)).map do |*content|
        Texier::Element.new('div', content)
      end
    end

    private

    def closing
      @closing ||= e(/\n\\--+ */).skip
    end
  end
end
