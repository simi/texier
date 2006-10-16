require File.dirname(__FILE__) + '/../module'

class Texy

    # Heading module class
    class HeadingModule < Module
        # Proc that will be called with newly created element
        attr_accessor :handler

        # level of top heading, 1 - 6
        attr_accessor :top

        # textual content of first heading
        attr_accessor :title

        attr_accessor :balancing

        LEVELS = { # when balancing = :fixed
            '#' => 0,
            '*' => 1,
            '=' => 2,
            '-' => 3,
        }

        def initialize(texy)
            super

            self.top = 1
            self.balancing = :dynamic

            self.allowed = {
                :surrounded = true,
                :underlined = true
            }

#             private $_rangeUnderline;
#             private $_deltaUnderline;
#             private $_rangeSurround;
#             private $_deltaSurround;
        end

        # Module initialization.
        def init()
            if allowed[:underlined]
                texy.register_block_pattern(
                    method(:process_block_underline),
                    /^(\S.*?)#{PATTERN_MODIFIER_H}?\n(\#|\*|\=|\-){3,}?$/
                )
            end

            if allowed[:surrounded]
                texy.register_block_pattern(
                    method(:process_block_surround),
                    /^((\#|\=){2,}?)(?!\\2)(.+?)\\2*?#{PATTERN_MODIFIER_H}?()$/
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
            m_content, m_mod1, m_mod2, m_mod3, m_mod4, m_line = matches[1..-1]
            # matches:
            #    [1] => ...
            #    [2] => (title)
            #    [3] => [class]
            #    [4] => {style}
            #    [5] => >
            #
            #    [6] => ...

            el = Texy::HeadingElement.new(texy)
            el.level = LEVELS[m_line]
            if balancing == :dynamic
                @elements_underline < el
            end

            el.modifier.set_properties(m_mod1, m_mod2, m_mod3, m_mod4)
            el.parse(m_content.strip)

            if handler
                return unless handler.call(el)
            end

            parser.element.append_child(el)

            # document title
            if title.nil?
                self.title = el.to_html.strip_html_tags
            end

            # dynamic headings balancing
            @range_underline[0] = [@range_underline[0], el.level].min
            @range_underline[1] = [@range_underline[1], el.level].max

            delta = -@rangeUnderline[0]
            @elements_underline.each do |el|
                el.delta_level = delta
            end

            delta = @range_surround[0] + (@range_underline[1] ? (@range_underline[1] - @range_underline[0] + 1) : 0);
            @elements_surround.each do |el|
                el.delta_level = delta
            end
        end



        # Callback function (for blocks)
        #
        #   ### Heading .(title)[class]{style}>
        #
        def process_block_surround(parser, matches)
            m_line, m_char, m_content, m_mod1, m_mod2, m_mod3, m_mod4 = matches[1..-1]
            # [1] => ###
            # [2] => ...
            # [3] => (title)
            # [4] => [class]
            # [5] => {style}
            # [6] => >

            el = Texy::HeadingElement.new(texy)
            el.level = 7 - [7, [2, m_line.length].max].min

            if balancing == :dynamic
                @elements_surround << el
            end

            el.modifier.set_properties(m_mod1, m_mod2, m_mod3, m_mod4)
            el.parse(m_content.strip)

            if ($this->handler)
                if (call_user_func_array($this->handler, array($el)) === FALSE) return;

            $parser->element->appendChild($el);

            // document title
            if ($this->title === NULL) $this->title = strip_tags($el->toHtml());

            // dynamic headings balancing
            $this->_rangeSurround[0] = min($this->_rangeSurround[0], $el->level);
            $this->_rangeSurround[1] = max($this->_rangeSurround[1], $el->level);
            $this->_deltaSurround    = -$this->_rangeSurround[0] + ($this->_rangeUnderline[1] ? ($this->_rangeUnderline[1] - $this->_rangeUnderline[0] + 1) : 0);

        }
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
                self.tag = 'h' . [6, [1, level + delta_level + texy.heading_module.top].max].min
                super
            end
    end
end