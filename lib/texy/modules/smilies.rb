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

        # Automatic replacements module class
        class Smilies < Base
            # Proc that will be called with newly created element
            attr_accessor :handler

            attr_accessor :icons

            attr_accessor :root
            attr_accessor :icon_class

            def initialize(texy)
                super
                self.allowed = false
                self.icons = {
                    ':-)' => 'smile.gif',
                    ':-(' => 'sad.gif',
                    ';-)' => 'wink.gif',
                    ':-D' => 'biggrin.gif',
                    '8-O' => 'eek.gif',
                    '8-)' => 'cool.gif',
                    ':-?' => 'confused.gif',
                    ':-x' => 'mad.gif',
                    ':-P' => 'razz.gif',
                    ':-|' => 'neutral.gif',
                }
                self.root = 'images/smilies/'
            end

            # Module initialization.
            def init
                if allowed
                    pattern = []

                    icons.each do |key, value|
                        pattern << Regexp.quote(key) + '+'
                    end

                    texy.register_line_pattern(
                        method(:process_line),
                        /(^|[\\x00-\\x20])?(#{pattern.join('|')})/
                    )
                end
            end

            # Callback function: :-)
            def process_line(parser, matches)
                # (rane) HACK: fix is workaround, because ruby's regexpes don't support lookbehind.
                fix, match = matches[1..2]
                fix = fix.to_s

                el = ImageElement.new(texy)
                el.modifier.title = match
                el.modifier.classes << icon_class if icon_class

                # find the closest match
                icons.each do |key, value|
                    if match[0, key.length] == key
                        el.image.set(value, root, true)
                        break
                    end
                end

                if handler
                    return fix unless handler.call(el)
                end

                fix + parser.element.append_child(el)
            end
        end
    end
end