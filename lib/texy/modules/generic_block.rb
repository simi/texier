class Texy
    module Modules
        # Paragraph / generic module class
        class GenericBlock < Base
            # Callback that will be called with newly created element
            attr_accessor :handler

            # ...
            attr_accessor :merge_mode

            def initialize(texy)
                super
                self.merge_mode = true
            end


            def process_block(parser, content)
                str_blocks = if merge_mode
                    content.split /(\n{2,})/
                else
                    content.split /(\n(?!\ )|\n{2,})/
                end

                str_blocks.each do |str|
                    str.strip!
                    next if str.empty?
                    process_single_block(parser, str)
                end
            end



            # Callback function (for blocks)
            #
            #             ....  .(title)[class]{style}>
            #             ...
            #             ...
            #
            def process_single_block(parser, content)
                match_data = /\A(.*?)#{PATTERN_MODIFIER_H}?(\n.*?)?()\Z/m.match(content)

                m_content, m_content2 = match_data[1], match_data[6]
                mods = match_data.to_a[2..5]

                # ....
                #  ...  => \n
                m_content = (m_content.to_s + m_content2.to_s).strip
                if texy.merge_lines
                    m_content.gsub! /\n (\S)/, " \r\\1"
                    m_content.tr! "\n\r", " \n"
                end

                el = GenericBlockElement.new(texy)
                el.modifier.set_properties(*mods)
                el.parse(m_content)

                # specify tag
                if el.content_type == DomElement::CONTENT_TEXTUAL
                    el.tag = 'p'
                elsif mods.any?
                    el.tag = 'div'
                elsif el.content_type == DomElement::CONTENT_BLOCK
                    el.tag = ''
                else
                    el.tag = 'div'
                end

                # add <br />
                if !el.tag.empty? && el.content.include?("\n")
                    el_br = TextualElement.new(texy)
                    el_br.tag = 'br'
                    el.set_content(el.content.gsub("\n", el.append_child(el_br)), true)
                end

                if handler
                    return unless handler.call(el)
                end

                parser.element.append_child el
            end
        end
    end


    # Html element paragraph / div / transparent
    class GenericBlockElement < TextualElement
        attr_accessor :tag

        def initialize(texy)
            super
            self.tag = 'p'
        end
    end
end