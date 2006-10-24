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
    class Html

        # This module ensures that output will be well-formed html
        # (no crossed tags, no opening tags without corresponding closing tags, etc...)
        class WellForm

            AUTO_CLOSE = {
                'tbody' => {'thead' => true, 'tbody' => true, 'tfoot' => true, 'colgoup' => true},
                'colgroup' => {'thead' => true, 'tbody' => true, 'tfoot' => true, 'colgoup' => true},
                'dd' => {'dt' => true, 'dd' => true},
                'dt' => {'dt' => true, 'dd' => true},
                'li' => {'li' => true},
                'option' => {'option' => true},
                'p' => {
                    'address' => true, 'applet' => true, 'blockquote' => true, 'center' => true,
                    'dir' => true, 'div' => true, 'dl' => true, 'fieldset' => true, 'form' => true,
                    'h1' => true, 'h2' => true, 'h3' => true, 'h4' => true, 'h5' => true, 'h6' => true,
                    'hr' => true, 'isindex' => true, 'menu' => true, 'object' => true, 'ol' => true,
                    'p' => true, 'pre' => true, 'table' => true, 'ul' => true
                },
                'td' => {
                    'th' => true, 'td' => true, 'tr' => true, 'thead' => true,
                    'tbody' => true, 'tfoot' => true, 'colgoup' => true
                },
                'tfoot' => {'thead' => true, 'tbody' => true, 'tfoot' => true, 'colgoup' => true},
                'th' => {
                    'th' => true, 'td' => true, 'tr' => true, 'thead' => true,
                    'tbody' => true, 'tfoot' => true, 'colgoup' => true
                },
                'thead' => {'thead' => true, 'tbody' => true, 'tfoot' => true, 'colgoup' => true},
                'tr' => {'tr' => true, 'thead' => true, 'tbody' => true, 'tfoot' => true, 'colgoup' => true}
            }



            # Fix misplaced tags.
            #
            # For example, turn this
            #     <strong><em> ... </strong> ... </em>
            # into this
            #     <strong><em> ... </em></strong><em> ... </em>
            def process(text)
                tag_stack = []

                # <div><strong>hello</div><div>world</strong>

                text.gsub!(/<(\/?)([a-z_:][a-z0-9._:-]*?)(|\s.*?)(\/?)>()/im) do
                    m_closing, m_tag, m_attr, m_empty = !$1.empty?, $2, $3, !$4.empty?

                    if Texy::Html::EMPTY[m_tag] || m_empty
                        next m_closing ? '' : "<#{m_tag}#{m_attr}/>"
                    end

                    replacement = ''

                    if m_closing # closing tag
                        index = tag_stack.size - 1

                        tag_stack.reverse.each do |pair|
                            replacement += "</#{pair[:tag]}>"
                            break if pair[:tag] == m_tag
                            index -= 1
                        end

                        next '' if index < 0

                        if Texy::Html::BLOCK[m_tag]
                            tag_stack.slice!(index..-1)
                        else
                            tag_stack.delete_at(index)
                            tag_stack[index..-1].each do |pair|
                                replacement += "<#{pair[:tag]}#{pair[:attr]}>"
                            end
                        end
                    else # opening
                        while true
                            break unless pair = tag_stack.last
                            break unless AUTO_CLOSE[pair[:tag]] && AUTO_CLOSE[pair[:tag]][m_tag]

                            tag_stack.pop
                            replacement += "</#{pair[:tag]}>"
                        end

                        tag_stack << {:tag => m_tag, :attr => m_attr}
                        replacement += "<#{m_tag}#{m_attr}>"
                    end

                    replacement
                end



                tag_stack.reverse.each do |pair|
                    text += "</#{pair[:tag]}>"
                end

                text
            end
        end
    end
end