class Texy
    class Parser
        attr_accessor :element # TextualElement

        def initialize(element)
            self.element = element
        end

        def parse(text)
        end
    end



    # Internal parsing block structure
    class BlockParser < Parser

        # Match current line against RE.
        #
        # If succesfull, increments current position and returns matched data.
        def receive_next(pattern)
            if match_data = pattern.match(@text[@offset..-1])
                @offset += match_data[0].length + 1 # 1 = "\n"

                match_data.to_a
            else
                nil
            end
        end

        def move_backward(lines_count = 1)
            while @offset > 0
                @offset -= 1

                if @text[@offset - 1] == ?\n
                    lines_count -= 1

                    break if lines_count < 1
                end
            end

            @offset = [@offset, 0].max
        end

        def parse(text)
            # Initialization
            texy = element.texy

            @text = text
            @offset = 0

            pb = texy.block_patterns
            keys = (0..pb.size - 1).to_a
            arr_matches = []
            arr_pos = Array.new(pb.size, -1)

            # Parsing
            while true
                min_key = -1
                min_pos = text.length

                break if @offset >= min_pos

                keys.each_with_index do |key, index|
                    next unless key
                    next unless arr_pos[key]

                    if arr_pos[key] < @offset
                        delta = arr_pos[key] == -2 ? 1 :0

                        # (rane) Take substring of input string to emulate php's preg_match, which has
                        # "offset" parameter. (FIXME: this solution is not completely correct - see
                        # http://www.php.net/manual/en/function.preg-match.php - but perhaps it will work)
                        if match_data = pb[key][:pattern].match(text[(@offset + delta)..-1])
                            arr_matches[key] = match_data.to_a
                            arr_pos[key] = match_data.begin(0) + @offset + delta # (rane) add offset to obtain absolute position
                        else
                            keys[index] = nil
                            next
                        end
                    end

                    if arr_pos[key] == @offset
                        min_key = key
                        break
                    end

                    if arr_pos[key] < min_pos
                        min_pos = arr_pos[key]
                        min_key = key
                    end
                end

                next_offset = (min_key == -1) ? text.length : arr_pos[min_key]

                if next_offset > @offset
                    string = text[@offset, next_offset - @offset]
                    @offset = next_offset

                    texy.generic_block_module.process_block(self, string)
                    next
                end

                matches = arr_matches[min_key]

                @offset = arr_pos[min_key] + matches[0].length + 1 # 1 = \n

                ok = pb[min_key][:handler].call(self, matches)

                if ok == false || @offset <= arr_pos[min_key] # module rejects text
                    @offset = arr_pos[min_key] # turn offset back
                    arr_pos[min_key] = -2
                    next
                end

                arr_pos[min_key] = -1
            end
        end
    end



    # Internal parsing line structure
    class LineParser < Parser
        def parse(text)
            # Initialization
            texy = element.texy

            offset = 0
            hash_str_len = 0 # (rane) FIXME: this is not used. what is it for?
            pl = texy.line_patterns
            keys = (0..pl.size - 1).to_a
            arr_matches = []
            arr_pos = Array.new(pl.size, -1)

            # Parsing
            while true
                min_key = -1
                min_pos = text.length

                keys.each_with_index do |key, index|
                    next unless key

                    if arr_pos[key] < offset
                        delta = arr_pos[key] == -2 ? 1 : 0


                        if match_data = pl[key][:pattern].match(text[(offset + delta)..-1])
                            next if match_data[0].empty?

                            arr_pos[key] = match_data.begin(0) + offset + delta
                            arr_matches[key] = match_data.to_a
                        else
                            keys[index] = nil
                            next
                        end
                    end

                    if arr_pos[key] == offset
                        min_key = key
                        break
                    end

                    if arr_pos[key] < min_pos
                        min_pos = arr_pos[key]
                        min_key = key
                    end
                end

                break if min_key == -1

                px = pl[min_key]
                offset = arr_pos[min_key]
                replacement = px[:handler].call(self, arr_matches[min_key])
                len = arr_matches[min_key][0].length

                text[offset, len] = replacement

                delta = replacement.length - len

                keys.each do |key|
                    next unless key

                    if arr_pos[key] < offset + len
                        arr_pos[key] = -1
                    else
                        arr_pos[key] += delta
                    end
                end

                arr_pos[min_key] = -2
            end

            text = Html.html_chars(text, false, true)

            texy.modules.each do |mod|
                text = mod.line_post_process(text)
            end

            element.set_content(text, true)

            if element.content_type == DomElement::CONTENT_NONE
                s = text.gsub(/[#{HASH}]+/, '').strip
                unless s.empty?
                    element.content_type = DomElement::CONTENT_TEXTUAL
                end
            end
        end
    end



    # Internal html parsing structure
    class HtmlParser < Parser

        PATTERN = /<(\/?)([a-z][a-z0-9_:-]*)(|\s(?:[\sa-z0-9:-]|=\s*"[^"#{HASH}]*"|=\s*'[^\'#{HASH}]*'|=[^>#{HASH}]*)*)(\/?)>|<!--([^#{HASH}]*?)-->/i

        def parse(text)
            # Initialization
            texy = element.texy

            # (rane) attempt to emulate php's preg_match_all...
            matches = []
            offset = 0

            while offset < text.length
                match_data = PATTERN.match(text[offset..-1])

                break unless match_data

                matches << [match_data.begin(0) + offset, match_data.to_a]
                offset += match_data.end(0)
            end

            matches.reverse.each do |match|
                text[match[0], match[1][0].length] = texy.html_module.process(self, match[1])
            end

            text = Html.html_chars(text, false, true)

            element.set_content(text, true)
            # (rane) FIXME: shouldn't there be = instead of == ?
            element.content_type == DomElement::CONTENT_BLOCK
        end
    end
end