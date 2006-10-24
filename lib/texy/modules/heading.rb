class Texy
    module Modules
        # Heading module class
        class Heading < Base
            # Proc that will be called with newly created element
            attr_accessor :handler

            # level of top heading, 1 - 6
            attr_accessor :top

            # textual content of first heading
            attr_accessor :title

            attr_accessor :balancing

            # when balancing = :fixed
            attr_accessor :levels

            def initialize(texy)
                super

                self.top = 1
                self.balancing = :dynamic
                self.levels = {
                    '#' => 0,
                    '*' => 1,
                    '=' => 2,
                    '-' => 3,
                }

                self.allowed = {
                    :surrounded => true,
                    :underlined => true
                }
            end

            # Module initialization.
            def init
                if allowed && allowed[:underlined]
                    texy.register_block_pattern(
                        method(:process_block_underline),
                        /^(\S.*?)#{PATTERN_MODIFIER_H}?\n(#|\*|=|-){3,}$/
                    )
                end

                if allowed && allowed[:surrounded]
                    texy.register_block_pattern(
                        method(:process_block_surround),
                        /^((#|=){2,})(?!\2)(.+?)\2*#{PATTERN_MODIFIER_H}?()$/ # (rane) TODO: wtf is the final "()" doing there?
                    )
                end
            end

            def pre_process(text)
                @range_underline = [10, 0]
                @range_surround = [10, 0]
                self.title = nil

                @elements_underline = []
                @elements_surround = []

                text
            end

            # Callback function (for blocks)
            #
            #   Heading .(title)[class]{style}>
            #   -------------------------------
            #
            def process_block_underline(parser, matches)
                m_content, m_line = matches.values_at(1, -1)

                el = Texy::HeadingElement.new(texy)
                el.level = levels[m_line]

                @elements_underline << el if balancing == :dynamic

                el.modifier.set_properties(*matches[2..-2])
                el.parse(m_content.strip)

                if handler
                    return unless handler.call(el)
                end

                parser.element.append_child(el)

                # document title
                self.title ||= el.to_html.strip_html_tags

                # dynamic headings balancing
                @range_underline[0] = [@range_underline[0], el.level].min
                @range_underline[1] = [@range_underline[1], el.level].max

                delta = -@range_underline[0]
                @elements_underline.each do |el|
                    el.delta_level = delta
                end

                delta = -@range_surround[0] + (@range_underline[1] ? (@range_underline[1] - @range_underline[0] + 1) : 0);
                @elements_surround.each do |el|
                    el.delta_level = delta
                end
            end



            # Callback function (for blocks)
            #
            #   ### Heading .(title)[class]{style}>
            #
            def process_block_surround(parser, matches)
                m_line, m_char, m_content = matches[1..3]

                el = Texy::HeadingElement.new(texy)
                el.level = 7 - [7, [2, m_line.length].max].min

                @elements_surround << el if balancing == :dynamic

                el.modifier.set_properties(*matches[4..-1])
                el.parse(m_content.strip)

                if handler
                    return unless handler.call(el)
                end

                parser.element.append_child(el)

                # document title
                self.title ||= el.to_html.strip_html_tags


                # dynamic headings balancing
                @range_surround[0] = [@range_surround[0], el.level].min
                @range_surround[1] = [@range_surround[1], el.level].max

                delta = -@range_surround[0] + (@range_underline[1] != 0 ? @range_underline[1] - @range_underline[0] + 1 : 0)
                @elements_surround.each do |el|
                    el.delta_level = delta
                end
            end
        end
    end


    # Html element h1-6
    class HeadingElement < TextualElement
        attr_accessor :level
        attr_accessor :delta_level

        def initialize(texy)
            super

            self.level = 0
            self.delta_level = 0
        end

        protected
            def generate_tags(tags)
                self.tag = 'h' + [6, [1, level + delta_level + texy.heading_module.top].max].min.to_s
                super
            end
    end
end