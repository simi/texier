class Texy
    module Modules

        # Table module class
        class Table < Base
            # Proc that will be called with newly created element
            attr_accessor :handler

            attr_accessor :odd_class
            attr_accessor :even_class

            def initialize(texy)
                super

                self.odd_class = nil
                self.even_class = nil
            end

            # Module initialization.
            def init
                texy.register_block_pattern(
                    method(:process_block),
                    /^(?:#{PATTERN_MODIFIER_HV}\n)?\|.*?()$/
                )
            end

            # Callback function (for blocks)
            #
            #    .(title)[class]{style}>
            #    |------------------
            #    | xxx | xxx | xxx | .(..){..}[..]
            #    |------------------
            #    | aa  | bb  | cc  |
            #
            def process_block(parser, matches)
                el = TableElement.new(texy)
                el.modifier.set_properties(*matches[1..-1])

                parser.move_backward

                if matches = parser.receive_next(/\A\|(#|\=){2,}(?!\1)(.*?)\1*\|?\ *#{PATTERN_MODIFIER_H}?()$/)
                    m_content = matches[2]

                    el.caption = TextualElement.new(texy)
                    el.caption.tag = 'caption'
                    el.caption.parse(m_content)
                    el.caption.modifier.set_properties(*matches[3..6])
                end

                @head = false
                @col_modifier = []
                @last = []
                @row = 0

                while true
                    if parser.receive_next(/\A\|\-{3,}$/)
                        @head = !@head
                        next
                    end

                    if el_row = process_row(parser)
                        if handler
                            next unless handler.call(el_row, :row)
                        end

                        el.append_child(el_row)
                        @row += 1
                        next
                    end

                    break
                end

                if handler
                    return unless handler.call(el, :table)
                end

                parser.element.append_child(el)
            end

            protected
                def process_row(parser)

                    return false unless matches = parser.receive_next(/\A\|(.*?)(?:|\|\ *#{PATTERN_MODIFIER_HV}?)()$/)

                    m_content = matches[1]

                    el_row = TableRowElement.new(texy)
                    el_row.modifier.set_properties(*matches[2..6])

                    if @row % 2 == 0
                        el_row.modifier.classes << odd_class if odd_class
                    else
                        el_row.modifier.classes << even_class if even_class
                    end

                    col = 0
                    el_field = nil

                    m_content.split('|', -1).each do |field| # (rane) -1 preserves trailing empty fields
                        if field == '' && el_field # colspan
                            el_field.col_span += 1
                            @last[col] = nil
                            col += 1
                            next
                        end

                        field.rstrip!
                        if field == '^' # rowspan
                            if @last[col]
                                @last[col].row_span += 1
                                col += @last[col].col_span
                                next
                            end
                        end

                        next unless matches = /\A(\*?)\ *#{PATTERN_MODIFIER_HV}?(.*?)#{PATTERN_MODIFIER_HV}?()$/.match(field)

                        m_head, m_content = matches.values_at(1, 7)
                        col_mods = matches[2..6]

                        if col_mods.any?
                            @col_modifier[col] = Modifier.new(texy)
                            @col_modifier[col].set_properties(*col_mods)
                        end

                        el_field = TableFieldElement.new(texy)
                        el_field.head = @head || m_head == '*'

                        el_field.modifier = @col_modifier[col].dup if @col_modifier[col]
                        el_field.modifier.set_properties(*matches[8..12])
                        el_field.parse(m_content)

                        el_row.append_child(el_field)
                        @last[col] = el_field
                        col += 1
                    end

                    el_row
                end
        end



        # Html element table
        class TableElement < BlockElement
            attr_accessor :caption

            def initialize(texy)
                super
                self.tag = 'table'
            end

            protected
                def generate_content
                    html = super

                    html = caption.to_html + html if caption
                    html
                end
        end



        # Html element tr
        class TableRowElement < BlockElement
            def initialize(texy)
                super
                self.tag = 'tr'
            end
        end



        # Html element td / th
        class TableFieldElement < TextualElement
            attr_accessor :col_span
            attr_accessor :row_span

            attr_writer :head
            def head?
                @head
            end

            def initialize(texy)
                super
                self.col_span = 1
                self.row_span = 1
            end

            protected
                def generate_tags(tags)
                    self.tag = head? ? 'th' : 'td'

                    super(tags) do |attrs|
                        attrs['colspan'] = col_span.to_s if col_span != 1
                        attrs['rowspan'] = row_span.to_s if row_span != 1
                        attrs
                    end
                end

                def generate_content
                    html = super
                    html.empty? ? '&#160;' : html
                end
        end
    end
end