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
        # Horizontal line module class
        class HorizLine < Base
            # Proc that will be called with newly created element
            attr_accessor :handler

            # Module initialization.
            def init
                texy.register_block_pattern(
                    method(:process_block),
                    /^(- |-|\* |\*){3,} *#{PATTERN_MODIFIER_H}?()$/
                )
            end


            # Callback function (for blocks)
            #
            #    ---------------------------
            #
            #    - - - - - - - - - - - - - -
            #
            #    ***************************
            #
            #    * * * * * * * * * * * * * *
            #
            def process_block(parser, matches)
                el = BlockElement.new(texy)
                el.tag = 'hr'
                el.modifier.set_properties(*matches[2..-1])

                if handler
                    return unless handler.call(el)
                end

                parser.element.append_child(el)
            end
        end
    end
end