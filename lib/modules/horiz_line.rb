require File.dirname(__FILE__) + '/../module'

class Texy

    # Horizontal line module class
    class HorizLineModule < Module
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