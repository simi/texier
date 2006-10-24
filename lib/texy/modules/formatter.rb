##########################################################################################
#
# This file is part of TexieR - universal text to html converter.
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

class Texy
    module Modules
        class Formatter < Base
            attr_accessor :base_indent # indent for top elements
            attr_accessor :line_wrap # line width, doesn't include indent space
            attr_accessor :indent

            def initialize(texy)
                super

                self.base_indent = 0
                self.line_wrap = 80
                self.indent = true
            end

            def post_process(text)
                return text unless allowed

                space = base_indent
                hash_table = {}

                # freeze all pre, textarea, script and style elements
                counter = 0
                text.gsub!(/<(pre|textarea|script|style)(.*?)<\/\1>/im) do |match|
                    # create new unique key for matched string
                    # and saves pair (key => str) into hash_table
                    key = "<#{$1}>\x1A#{counter.to_s(4).tr('0123', "\x1B\x1C\x1D\x1E")}\x1A</#{$1}>"
                    counter += 1

                    hash_table[key] = match
                    key
                end

                # remove \n
                text.gsub!("\n", ' ')

                # shrink multiple spaces
                text.gsub!(/ +/, ' ')

                # indent all block elements + br
                text.gsub!(/ *<(\/?)(#{Texy::Html::BLOCK.keys.join('|')}|br)(>| [^>]*>) */i) do |match|
                    # Insert \n + spaces into HTML code

                    m_closing, m_tag = $1, $2
                    # [1] => /  (opening or closing element)
                    # [2] => element


                    match.strip!
                    m_tag.downcase!

                    if m_tag == 'br' # exception
                        "\n#{"\t" * [0, space - 1].max}#{match}"
                    elsif Texy::Html::EMPTY[m_tag]
                        "\r#{"\t" * space}#{match}\r#{"\t" * space}"
                    elsif m_closing == '/'
                        space -= 1
                        "\x08#{match}\n#{("\t" * space)}" # \x08 is backspace
                    else
                        space += 1
                        "\n#{"\t" * (space - 1)}#{match}"
                    end
                end

                # right trim
                text.gsub!(/[\t ]+(\n|\r|$)/, '\1')

                # join double \r to single \n
                text.gsub!("\r\r", "\n")
                text.gsub!("\r", "\n")

                # "backtabulators"
                text.gsub!("\t\x08", '')
                text.gsub!("\x08", '')

                # line wrap
                if line_wrap > 0
                    text.gsub!(/^(\t*)(.*)$/) do
                        # wrap lines
                        $1 + $2.word_wrap(line_wrap).gsub("\n", "\n#{$1}")
                    end
                end

                # unfreeze pre, textarea, script and style elements
                hash_table.each do |from, to|
                    text.gsub!(from, to)
                end

                text
            end
        end
    end
end