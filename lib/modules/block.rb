require File.dirname(__FILE__) + '/../module'

class Texy

    # Block module class
    class BlockModule < Module
        # proc(element)
        attr_accessor :code_handler
        # proc(element, non_parsed_content)
        attr_accessor :div_handler
        # proc(element, is_html)
        attr_accessor :html_handler


        def initialize(texy)
            super

            self.allowed = {
                :pre => true,
                :text => true, # if false, /--html blocks are parsed as /--text block
                :html => true,
                :div => true,
                :source => true,
                :comment => true
            }
        end

        # Module initialization.
        def init
            texy.register_block_pattern(
                method(:process_block),
                /^\/--+ *(?:(code|samp|text|html|div|notexy|source|comment)( .*?)?|) *#{PATTERN_MODIFIER_H}?\n(.*?\n)?(?:\\--+ *\1?|\z)()$/mi
            )
        end



        # Callback function (for blocks)
        #
        #    /-----code html .(title)[class]{style}
        #        ....
        #        ....
        #    \----
        #
        def process_block(parser, matches)
            m_type, m_second, m_content = matches.values_at(1, 2, 7)

            m_second = m_second.downcase.strip
            m_content.gsub!(/\A\n+|\n+\Z/, '') #trim($mContent, "\n");

            m_type ||= 'pre' # default type
            m_type = m_type.downcase.strip

            m_type = 'html' if m_type == 'notexy' # backward compatibility
            m_type = 'text' if m_type == 'html' && !allowed[:html]

            if m_type == 'code' || m_type == 'samp'
                m_type = allowed[:pre] ? m_type : 'none'
            elsif !allowed[m_type.to_sym]
                m_type = 'none' # transparent block
            end

            case m_type
            when 'none', 'div'
                el = BlockElement.new(texy)
                el.tag = 'div'
                el.modifier.set_properties(*matches[3..6])

                outdent(m_content)

                if div_handler
                    return unless div_handler.call(el, m_content)
                end

                el.parse(m_content)
                parser.element.append_child(el)

            when 'source'
                el = SourceBlockElement.new(texy)
                el.modifier.set_properties(*matches[3..6])

                outdent(m_content)

                el.parse(m_content)
                parser.element.append_child(el)

            when 'comment'

            when 'html'
                el = HtmlBlockElement.new(texy)
                el.parse(m_content)

                if html_handler
                    return unless html_handler.call(el, true)
                end

                parser.element.append_child(el)

            when 'text'
                el = TextualElement.new(texy)
                el.set_content(Html::html_chars(m_content).gsub("\n", '<br />'), true)

                if html_handler
                    return unless html_handler.call(el, false)
                end

                parser.element.append_child(el)

            else # pre | code | samp
                el = CodeBlockElement.new(texy)
                el.modifier.set_properties(*matches[3..6])
                el.type = m_type
                el.lang = m_second

                outdent(m_content)

                el.set_content(m_content, false) # not html-safe content

                if code_handler
                    return unless code_handler.call(el)
                end

                parser.element.append_child(el)
            end
        end

        private
            # outdent
            def outdent(text)
                if (spaces = text.index(/\S/) > 0)
                    text.gsub!(/^ {1,#{spaces}}/, '')
                end
            end

    end



    # Html element pre + code
    class CodeBlockElement < TextualElement
        attr_accessor :lang, :type

        def initialize(texy)
            super
            self.tag = 'pre'
        end


        def generate_tags(tags)
            super

            if self.tag # (rane) maybe !tag.empty?
                tags.each do |(tag, attrs)|
                    if tag == self.tag
                        attrs[:class] << lang

                        tags << [type, {}] if type # (rane) maybe !type.empty?
                        break
                    end
                end
            end
        end
    end



    # Html element
    class HtmlBlockElement < TextualElement
        def parse(text)
            parser = HtmlParser.new(self)
            parser.parse(text)
        end
    end



    class SourceBlockElement < BlockElement
        def initialize(texy)
            super
            self.tag = 'pre'
        end

        protected
            def generate_content
                html = super
                html = texy.formatter_module.post_process(html) if texy.formatter_module

                el = CodeBlockElement.new(texy)
                el.lang = 'html'
                el.type = 'code'
                el.set_content(html, false)

                if texy.block_module.code_handler
                    texy.block_module.code_handler.call(el)
                end

                el.safe_content
            end
    end
end