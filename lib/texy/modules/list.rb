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

        # (rane) FIXME: there is a bug (which is also in original version).
        # When there is alphabetic list:
        #
        #    a) foo
        #    b) bar
        #    c) baz
        #
        # Followed immediately by roman-numerals list:
        #
        #    i) hello
        #    ii) world
        #
        # Then the first item of the roman list will be consumed by the alphabetic list.
        #
        # This bug accurs because, technicaly, "i)" is letter as well as roman numeral.
        #
        # That situation will hardly occur in real world, so it is not so serious propblem,
        # but still it is a bug.



        # Ordered / unordered nested list module class
        class List < Base
            # Proc that will be called with newly created element
            attr_accessor :handler

            attr_accessor :translate

            def initialize(texy)
                super
                self.allowed = {
                    '*' => true,
                    '-' => true,
                    '+' => true,
                    '1.' => true,
                    '1)' => true,
                    'I.' => true,
                    'I)' => true,
                    'a)' => true,
                    'A)' => true
                }

                self.translate = [
                    #          rexexp,         class,  list-style-type,    tag
                    [   '*',   '\*',           '',     '',                 'ul'    ],
                    [   '-',   '\-',           '',     '',                 'ul'    ],
                    [   '+',   '\+',           '',     '',                 'ul'    ],
                    [   '1.',  '\d+\.\ ',      '',     '',                 'ol'    ],
                    [   '1)',  '\d+\)',        '',     '',                 'ol'    ],
                    [   'I.',  '[IVX]+\.\ ',   '',     'upper-roman',      'ol'    ], # place romans before alpha
                    [   'I)',  '[IVX]+\)',     '',     'upper-roman',      'ol'    ],
                    [   'a)',  '[a-z]\)',      '',     'lower-alpha',      'ol'    ],
                    [   'A)',  '[A-Z]\)',      '',     'upper-alpha',      'ol'    ],
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
                    /^(?:#{PATTERN_MODIFIER_H}\n)?(#{bullets.join('|')})(\n?)\ +\S.*?$/
                )
            end

            # Callback function (for blocks)
            #
            #    1) .... .(title)[class]{style}>
            #    2) ....
            #        + ...
            #        + ...
            #    3) ....
            #
            def process_block(parser, matches)
                m_bullet, m_new_line = matches[5..6]

                el = ListElement.new(texy)
                el.modifier.set_properties(*matches[1..4])

                bullet = ''
                translate.each do |type|
                    if /\A#{type[1]}/ =~ m_bullet
                        bullet = type[1]
                        el.tag = type[4]
                        el.modifier.styles['list-style-type'] = type[3]
                        el.modifier.classes << type[2]
                        break
                    end
                end

                parser.move_backward(m_new_line.empty? ? 1 : 2)

                count = 0
                while el_item = process_item(parser, bullet)
                    el.append_child(el_item)
                    count += 1
                end

                return false if count == 0

                if handler
                    return unless handler.call(el)
                end

                parser.element.append_child(el)
            end

            def process_item(parser, bullet, indented = false)
                spaces_base = indented ? '\ {1,}' : ''
                pattern_item = /\A\n?(#{spaces_base})#{bullet}(\n?)(\ +)(\S.*?)?#{PATTERN_MODIFIER_H}?()$/

                # first line (with bullet)
                return false unless matches = parser.receive_next(pattern_item)

                m_indent, m_new_line, m_space, m_content = matches[1..4]

                el_item = ListItemElement.new(texy)
                el_item.tag = 'li'
                el_item.modifier.set_properties(*matches[5..8])

                # next lines
                spaces = m_new_line.empty? ? '' : m_space.length
                content = " #{m_content}" # trick

                while matches = parser.receive_next(/\A(\n*)#{m_indent}(\ {1,#{spaces}})(.*)()$/)
                    m_blank, m_spaces, m_content = matches[1..3]

                    spaces = m_spaces.length if spaces == ''
                    content += "\n#{m_blank}#{m_content}"
                end

                # parse content
                saved_merge_mode = texy.generic_block_module.merge_mode
                texy.generic_block_module.merge_mode = false

                el_item.parse(content)

                texy.generic_block_module.merge_mode = saved_merge_mode

                el_item.child_at(0).tag = '' if el_item.child_at(0).kind_of?(GenericBlockElement)
                el_item
            end
        end
    end


    # Html element ol / ul / dl
    class ListElement < BlockElement
    end



    # Html element li / dl
    class ListItemElement < BlockElement
    end
end