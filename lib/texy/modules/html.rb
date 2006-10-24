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
        # Html tags module class
        class Html < Base
            # Proc that will be called with newly created element */
            attr_accessor :handler

            attr_accessor :allowed_comments

            SAFE_TAGS = {
                'a' => ['href', 'rel', 'title', 'lang'],
                'abbr' => ['title', 'lang'],
                'acronym' => ['title', 'lang'],
                'b' => ['title', 'lang'],
                'br' => [],
                'cite' => ['title', 'lang'],
                'code' => ['title', 'lang'],
                'dfn' => ['title', 'lang'],
                'em' => ['title', 'lang'],
                'i' => ['title', 'lang'],
                'kbd' => ['title', 'lang'],
                'q' => ['cite', 'title', 'lang'],
                'samp' => ['title', 'lang'],
                'small' => ['title', 'lang'],
                'span' => ['title', 'lang'],
                'strong' => ['title', 'lang'],
                'sub' => ['title', 'lang'],
                'sup' => ['title', 'lang'],
                'var' => ['title', 'lang'],
            }

            def initialize(texy)
                super
                self.allowed = texy.allowed_tags
                self.allowed_comments = true
            end

            # Module initialization.
            def init
                texy.register_line_pattern(method(:process), HtmlParser::PATTERN)
            end

            # Callback function: <tag ...>  | <!-- comment -->
            def process(parser, matches)
                match, m_closing, m_tag, m_attr, m_empty, m_comment = matches

                unless m_tag # comment
                    return m_comment[0] == ?[ ? match : '' unless allowed_comments

                    el = TextualElement.new(texy)
                    el.content_type = DomElement::CONTENT_NONE
                    el.set_content(match, true)

                    return parser.element.append_child(el)
                end

                return match unless texy.allowed_tags # disabled

                tag = m_tag.downcase
                tag = m_tag unless Texy::Html::VALID[tag] # undo lowercase

                empty = (m_empty == '/') || Texy::Html::EMPTY[tag]
                is_opening = m_closing != '/'

                return match if empty && !is_opening # error - can't close empty element
                return match if texy.allowed_tags.kind_of?(Hash) && texy.allowed_tags[tag].nil? # is element allowed?

                el = HtmlTagElement.new(texy)
                el.content_type = Texy::Html::INLINE[tag] ? DomElement::CONTENT_NONE : DomElement::CONTENT_BLOCK

                if is_opening # process attributes
                    attrs = {}
                    allowed_attrs = texy.allowed_tags.kind_of?(Hash) ? texy.allowed_tags[tag] : nil

                    m_attr.scan(/([a-z0-9:-]+)\s*(?:=\s*('[^']*'|"[^"]*"|[^'"\s]+))?()/im) do |key, value|
                        key.downcase!

                        next if allowed_attrs.kind_of?(Array) && !allowed_attrs.include?(key)

                        if value.nil?
                            value = key
                        elsif value[0] == ?' || value[0] == ?"
                            value = value[1..-2]
                        end

                        attrs[key] = value
                    end

                    # apply allowed_classes & allowed_styles
                    modifier = Modifier.new(texy)

                    if attrs['class']
                        modifier.parse_classes(attrs['class'])
                        attrs['class'] = modifier.classes
                    end

                    if attrs['style']
                        modifier.parse_styles(attrs['style'])
                        attrs['style'] = modifier.styles
                    end

                    if attrs['id']
                        if texy.allowed_classes.nil?
                            attrs.delete('id')
                        elsif texy.allowed_classes.kind_of?(Hash) && !texy.allowed_classes.include?("##{attrs['id']}")
                            attrs.delete('id')
                        end
                    end

                    case tag
                        when 'img'
                            return match unless attrs['src']
                            texy.summary[:images] << attrs['src']
                        when 'a'
                            return match unless attrs['href'] || attrs['name'] || attrs['id']

                            texy.summary[:links] << attrs['href'] if attrs['href']
                    end

                    attrs[Texy::Html::EMPTY_TAG] = true if empty
                    el.tags << [tag, attrs]
                    el.opening = true
                else # closing tag
                    el.tags << [tag, {}]
                    el.opening = false
                end

                if handler
                    return '' unless handler.call(el)
                end

                parser.element.append_child(el)
            end



            def trust_mode(only_valid_tags = true)
                texy.allowed_tags = only_valid_tags ? Texy::Html::VALID : :all
            end

            def safe_mode(allow_safe_tags = true)
                texy.allowed_tags = allow_safe_tags ? SAFE_TAGS : nil
            end
        end
    end


    class HtmlTagElement < DomElement
        def initialize(texy)
            super
            self.tags = []
        end

        attr_accessor :tags

        def opening?
            @opening
        end
        attr_writer :opening

        # convert element to HTML string
        def to_html
            if opening?
                Html.opening_tags(tags)
            else
                Html.closing_tags(tags)
            end
        end
    end
end