class Texy
    # DOM element base class
    class DomElement
        CONTENT_NONE = 1
        CONTENT_TEXTUAL = 2
        CONTENT_BLOCK = 3

        # parent Texy object
        attr_accessor :texy
        attr_accessor :content_type
        attr_accessor :behave_as_opening # !!!

        def initialize(texy)
            self.texy = texy
            self.content_type = CONTENT_NONE
        end

        # Convert element to HTML string
        def to_html
        end

        protected
            # for easy Texy! DOM manipulation
            def broadcast
                # build dom.elements list
                texy.dom.elements << self
            end
    end



    # This class represents one HTML element
    class HtmlElement < DomElement
        attr_accessor :modifier
        attr_accessor :tag

        def initialize(texy)
            super
            self.modifier = Modifier.new(texy)
        end


        protected

            # Generate HTML element tags
            def generate_tags(tags)
                if tag
                    attrs = modifier.attrs_of(tag)
                    attrs[:id] = modifier.id

                    if modifier.title
                        attrs[:title] = modifier.title
                    end

                    attrs[:class] = modifier.classes
                    attrs[:style] = modifier.styles


                    attrs[:style]['text-align'] = modifier.h_align if modifier.h_align
                    attrs[:style]['vertical-align'] = modifier.v_align if modifier.v_align

                    tags << [tag, attrs]
                end
            end

            # Generate HTML element content
            def generate_content
            end

        public

            # Convert element to HTML string
            def to_html
                tags = []
                generate_tags tags

                Html.opening_tags(tags) + generate_content + Html.closing_tags(tags)
            end

        protected

            def broadcast
                super

                # build texy.dom.elements_by_id list
                texy.dom.elements_by_id[modifier.id] = self if modifier.id

                # build texy.dom.elements_by_class list
                unless modifier.classes.empty?
                    modifier.classes.each do |klass|
                        texy.dom.elements_by_class[klass] ||= []
                        texy.dom.elements_by_class[klass] << self
                    end
                end
            end
    end



    # This element represent array of other blocks (HtmlElement)
    class BlockElement < HtmlElement
        def initialize(texy)
            super
            @children = []
        end

        # child must be BlockElement or TextualElement
        def append_child(child)

            # (rane) This was already commented out in original version:
            # unless child.kind_of?(BlockElement) || child.kind_of?(TextualElement)
            #     raise ArgumentError, 'Only InlineTagElement allowed'
            # end

            @children << [nil, child]

            self.content_type = [self.content_type, child.content_type].max
        end

        def child_at(key)
            @children.find do |item|
                item[0] == key
            end[1] rescue nil
        end

        protected

            def generate_content
                @children.inject('') do |html, child|
                    html += child[1].to_html
                end
            end

        public

            # Parse +text+ as BLOCK and create array of children (array of Texy DOM elements)
            def parse(text)
                parser = BlockParser.new(self)
                parser.parse(text)
            end

        protected

            def broadcast
                super

                # apply to all children
                @children.map do |(key, child)|
                    child.broadcast
                end
            end
    end



    # This element represent one line of text.
    #
    # Text represents +content+ and +children+ is array of InlineTagElement
    class TextualElement < BlockElement

        def initialize(texy)
            super

            # is content HTML-safe?
            @html_safe = false
            @content = ''
        end



        attr_reader :content

        def set_content(text, html_safe = false)
            @content = text;
            @html_safe = html_safe
        end

        def safe_content(only_return = false)
            safe_content = if @html_safe then content else Html.html_chars(content) end

            if only_return
                safe_content
            else
                @html_safe = true
                @content = safe_content
            end
        end

        protected

            def generate_content
                set_content(safe_content(true))

                unless @children.empty?
                    @children.each do |(key, child)|
                        child.behave_as_opening = Texy.hash_opening?(key)
                        content.gsub! key, child.to_html
                    end
                end

                content
            end

        public

            # Parse +text+ as SINGLE LINE and create string +content+ and array of Texy DOM elements (+children+)
            def parse(text)
                parser = LineParser.new(self)
                parser.parse(text)
            end

        protected

            # Generate unique HASH key - useful for freezing (folding) some substrings
            # Key consist of unique chars \x19, \x1B-\x1E (noncontent) (or \x1F detect opening tag)
            #                             \x1A, \x1B-\x1E (with content)
            def hash_key(content_type = nil, opening = false)
                border = if content_type == CONTENT_NONE then "\x19" else "\x1A" end

                border +
                if opening then "\x1F" else "" end +
                @children.size.to_s(4).tr('0123', "\x1B\x1C\x1D\x1E") +    ## wtf?
                border
            end

# (rane) FIXME This method is already defined in class Texy
#             /**
#              *
#              */
#             protected function isHashOpening($hash)
#             {
#                 return $hash{1} == "\x1F";
#             }
#
        public

            def append_child(child, inner_text = nil)
                self.content_type = [self.content_type, child.content_type].max

                if child.kind_of? InlineTagElement
                    key_open = hash_key(child.content_type, true)
                    key_close = hash_key(child.content_type, false)

                    @children << [key_open, child]
                    @children << [key_close, child]

                    key_open + inner_text + key_close
                else
                    key = hash_key child.content_type
                    @children << [key, child]
                    key
                end
            end
    end



    # Represent HTML tags (elements without content)
    # Used as children of TextualElement
    class InlineTagElement < HtmlElement

        # convert element to HTML string
        def to_html
            if behave_as_opening
                tags = []
                generate_tags tags

                @closing_tag = Html.closing_tags(tags)

                Html.opening_tags tags
            else
                @closing_tag
            end
        end
    end



    # Note by rane:
    # in the original PHP code, this stuff was defined in class Dom and also in class DomLine.
    # That was not DRY, therefore i separated it out into this module.
    module DomEasyAccess
        def included(base)
            base.attr_reader :elements
            base.attr_reader :elements_by_id
            base.attr_reader :elements_by_class
        end

        # Build list for easy access to DOM structure
        def build_lists
            @elements = []
            @elements_by_id = {}
            @elements_by_class = {}

            broadcast
        end
    end


    # Texy! DOM
    class Dom < BlockElement
        include DomEasyAccess

        # Convert Texy! document into DOM structure
        #
        # Before converting it normalize text and call all pre-processing modules
        def parse(text)
            # Remove special chars, normalize lines.
            text = Texy.wash(text)

            # Standardize line endings to unix-like (dos, mac).
            text.gsub! "\r\n", NEW_LINE # DOS
            text.gsub! "\r", NEW_LINE # Mac

            # Replace tabs with spaces.
            tab_width = texy.tab_width

            while text.include?("\t")
                text.gsub! /^(.*)\t/ do
                    $1 + ' ' * ((tab_width - $1.length) % tab_width)
                end
            end

            # Remmove Texy! comments.
            comment_chars = if texy.utf then "\xC2\xA7" else "\xA7" end

            text.gsub! /#{comment_chars}{2,}(?!#{comment_chars}).*(#{comment_chars}{2,}|$)(?!#{comment_chars})/m, ''

            # Right trim.
            text.gsub /[\t ]+$/m, ''


            # Pre-processing.
            texy.modules.each do |mod|
                text = mod.pre_process(text)
            end

            # Process.
            super
        end



        # Convert DOM structure to (X)HTML code
        # and call all post-processing modules
        def to_html
            html = super

            html = Html::WellForm.new.process(html)

            # Post-process.
            texy.modules.each do |mod|
                html = mod.post_process(html)
            end

            # Unfreeze spaces.
            html = Texy.unfreeze_spaces(html)
            html = Html.check_entities(html)

            # This notice should remain!
            unless texy.notice_shown?
                html += "\n<!-- generated by Texy! -->"
                texy.notice_shown = true
            end

            html
        end



        attr_reader :elements # (rane) FIXME: is this even used?
        attr_reader :elements_by_id
        attr_reader :elements_by_class

        # Build list for easy access to DOM structure
        def build_lists
            @elements = []
            @elements_by_id = {}
            @elements_by_class = {}

            broadcast
        end
    end



    # Texy! DOM for single line
    class DomLine < TextualElement
        include DomEasyAccess

        # Convert Texy! single line into DOM structure
        def parse(text)
            # Remove special chars and line endings.
            text = Texy.wash(text)
            text = text.gsub("\n", ' ').gsub("\r", '').rstrip

            # Process.
            super
        end



        # Convert DOM structure to (X)HTML code
        def to_html
            html = super
            html = WellForm.new.process(html)
            html = Texy.unfreeze_spaces(html)
            html = Html.check_entities(html)

            html
        end
    end
end