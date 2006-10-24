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

require File.dirname(__FILE__) + '/list'

class Texy
    module Modules

        # Definition list module class
        class DefinitionList < List

            def initialize(texy)
                super
                self.allowed = {
                    '*' => true,
                    '-' => true,
                    '+' => true
                }

                self.translate = [
                    ['*', '\*', ''],
                    ['-', '\-', ''],
                    ['+', '\+', '']
                ]
            end

            # Module initialization.
            def init
                bullets = []

                translate.each do |t|
                    bullets << t[1] if allowed[t[0]]
                end

                texy.register_block_pattern(
                    method(:process_block),
                    /^(?:#{PATTERN_MODIFIER_H}\n)?(\S.*?)\:\ *#{PATTERN_MODIFIER_H}?\n(\ +)(#{bullets.join('|')})\ +\S.*?$/
                )
            end

            # Callback function (for blocks)
            #
            #    Term: .(title)[class]{style}>
            #        - description 1
            #        - description 2
            #        - description 3
            #
            def process_block(parser, matches)
                m_content_term, m_spaces, m_bullet = matches.values_at(5, 10, 11)

                el = ListElement.new(texy)
                el.modifier.set_properties(*matches[1..4])
                el.tag = 'dl'

                bullet = ''
                type = translate.find do |type|
                    /\A#{type[1]}/ =~ m_bullet
                end

                bullet = type[1]
                el.modifier.classes << type[2]



                parser.move_backward(2)

                pattern_term = /\A\n?(\S.*?)\:\ *#{PATTERN_MODIFIER_H}?()$/

                while true
                    if el_item = process_item(parser, Regexp.quote(m_bullet), true)
                        el_item.tag = 'dd'
                        el.append_child(el_item)
                        next
                    end

                    if matches = parser.receive_next(pattern_term)
                        el_item = TextualElement.new(texy)
                        el_item.tag = 'dt'
                        el_item.modifier.set_properties(*matches[2..5]);
                        el_item.parse(matches[1])
                        el.append_child(el_item)
                        next
                    end

                    break
                end

                if handler
                    return unless handler.call(el)
                end

                parser.element.append_child(el)
            end
        end
    end
end