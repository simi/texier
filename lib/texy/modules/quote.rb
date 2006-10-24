class Texy
    module Modules
        # Quote & blockquote module class
        class Quote < Base
            # Proc that will be called with newly created element
            attr_accessor :handler

            def initialize(texy)
                super

                self.allowed = {
                    :line => true,
                    :block => true
                }
            end

            # Module initialization.
            def init
                if allowed[:block]
                    texy.register_block_pattern(
                        method(:process_block),
                        /^(?:#{PATTERN_MODIFIER_H}\n)?>(\ +|:)(\S.*?)$/
                    )
                end

                if allowed[:line]
                    texy.register_line_pattern(
                        method(:process_line),
                        /(>>)(?!\ |\>)(.+?[^\ <])#{PATTERN_MODIFIER}?<<(?!<)#{PATTERN_LINK}?()/
                    )
                end
            end



            # Callback function: >>.... .(title)[class]{style}<<:LINK
            def process_line(parser, matches)
                m_mark, m_content, m_link = matches.values_at(1, 2, 6)

                el = QuoteElement.new(texy)
                el.modifier.set_properties(*matches[3..5])

                el.cite.set(m_link) if m_link

                if handler
                    return '' unless handler.call(el)
                end

                parser.element.append_child(el, m_content)
            end

            # Callback function (for blocks)
            #
            #    > They went in single file, running like hounds on a strong scent,
            #    and an eager light was in their eyes. Nearly due west the broad
            #    swath of the marching Orcs tramped its ugly slot; the sweet grass
            #    of Rohan had been bruised and blackened as they passed.
            #    >:http://www.mycom.com/tolkien/twotowers.html
            #
            def process_block(parser, matches)
                m_spaces, m_content = matches[5..6]

                el = BlockQuoteElement.new(texy)
                el.modifier.set_properties(*matches[1..4])

                content = ''
                link_target = nil
                spaces = ''

                while true
                    if m_spaces == ':'
                        link_target = m_content.strip
                    else
                        spaces = [1, m_spaces.length].max.to_s if spaces.empty?
                        content += m_content.to_s + "\n"
                    end

                    if matches = parser.receive_next(/\A>(?:|(\ {1,#{spaces}}|:)(.*))()$/)
                        m_spaces, m_content = matches[1..2]
                    else
                        break
                    end
                end

                if link_target
                    elx = LinkElement.new(texy)
                    elx.set_link_raw(link_target)
                    el.cite.set(elx.link.as_url)
                end

                el.parse(content)

                if handler
                    return unless handler.call(el)
                end

                parser.element.append_child(el)
            end
        end
    end


    # Html element blockquote
    class BlockQuoteElement < BlockElement
        attr_accessor :cite

        def initialize(texy)
            super
            self.tag = 'blockquote'
            self.cite = Url.new(texy)
        end

        protected
            def generate_tags(tags)
                super(tags) do |attrs|
                    attrs['cite'] = cite.as_url
                    attrs
                end
            end
    end



    # Html tag quote
    class QuoteElement < InlineTagElement
        attr_accessor :cite

        def initialize(texy)
            super
            self.tag = 'q'
            self.cite = Url.new(texy)
        end

        protected
            def generate_tags(tags)
                super(tags) do |attrs|
                    attrs['cite'] = cite.as_url
                    attrs
                end
            end
    end
end