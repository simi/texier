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

require 'cgi'

class Texy
    module Modules
        # Links module class
        class Link < Base
            # Proc that will be called with newly created element */
            attr_accessor :handler

            # options

            # root of relative links
            attr_accessor :root
            # 'this.href="mailto:"+this.href.match(/./g).reverse().slice(0,-7).join("")';
            attr_accessor :email_on_click
            # image popup event
            attr_accessor :image_on_click
            # popup popup event
            attr_accessor :popup_on_click
            # always use rel="nofollow" for absolute links
            attr_accessor :force_no_follow



            def initialize(texy)
                super

                self.allowed = {
                    :link => true, # classic link "xxx":URL and [reference]
                    :email => true, # emails replacement
                    :url => true, # direct url replacement
                    :quick_link => true, # quick link xxx:[url] or [reference]
                    :references => true, # [ref]: URL  reference definitions
                }

                self.email_on_click = nil
                self.force_no_follow = false
                self.image_on_click = 'return !popupImage(this.href)'
                self.popup_on_click = 'return !popup(this.href)'
            end



            # Module initialization.
            def init
                if allowed[:quick_link]
                    texy.register_line_pattern(
                        method(:process_line_quick),
                        /([\w0-9@#\$%&\.,_-]+?)(?=:\[)#{PATTERN_LINK}()/
                    )
                end

                # [reference]
                texy.register_line_pattern(method(:process_line_reference), /(#{PATTERN_LINK_REF})/)

                # direct url and email
                if allowed[:url]
                    texy.register_line_pattern(
                        method(:process_line_url),
                        /([\s^\(\[<:])((?:https?:\/\/|www\.|ftp:\/\/|ftp\.)[a-z0-9.-][\/a-z\d+\.~%&?@=_:;#,-]+[\/\w\d+~%?@=_#])/i
                    )
                end

                if allowed[:email]
                    texy.register_line_pattern(
                        method(:process_line_url),
                        /([\s^\(\[\<:])(#{PATTERN_EMAIL})/
                    )
                end
            end



            # Add new named image
            def add_reference(name, obj)
                texy.add_reference(name, obj)
            end

            # Receive new named link. If not exists, try
            # call user function to create one.
            def reference(ref_name)
                el = texy.reference(ref_name)
                query = ''

                unless el
                    query_pos = ref_name.index('?')
                    query_pos ||= ref_name.index('#')

                    if query_pos # try to extract ?... #... part
                        el = texy.reference(ref_name[0, query_pos])
                        query = ref_name[query_pos..-1]
                    end
                end

                return false unless el.kind_of?(LinkReference)

                el.query = query
                el
            end



            # Preprocessing
            def pre_process(text)
                # [la trine]: http://www.dgx.cz/trine/ text odkazu .(title)[class]{style}
                if allowed[:references]
                    text.gsub(/^\[([^\[\]#\?\*\n]+?)\]:\ +(#{PATTERN_LINK_IMAGE}|(?!\[)\S+)(\ .+?)?#{PATTERN_MODIFIER}?()$/) do
                        el_ref = LinkReference.new(texy, $2, $3)
                        el_ref.modifier.set_properties($4, $5, $6)

                        add_reference($1, el_ref)
                        ''
                    end
                else
                    text
                end
            end



            # Callback function: ....:LINK
            def process_line_quick(parser, matches)
                m_content, m_link = matches[1..2]

                return m_content unless allowed[:quick_link]

                el_link = LinkElement.new(texy)
                el_link.set_link_raw(m_link, m_content)

                parser.element.append_child(el_link, m_content)
            end

            # Callback function: [ref]
            def process_line_reference(parser, matches)
                match, m_ref = matches

                return match unless allowed[:link]

                el_link = LinkRefElement.new(texy)

                return match unless el_link.set_link(m_ref)

                parser.element.append_child(el_link)
            end

            # Callback function: http://www.dgx.cz
            def process_line_url(parser, matches)
                el_link = LinkElement.new(texy)
                el_link.set_link_raw(matches[2])

                matches[1] + parser.element.append_child(el_link, el_link.link.as_textual)
            end
        end
    end


    class LinkReference
        attr_accessor :url
        attr_accessor :query
        attr_accessor :label
        attr_accessor :modifier

        def initialize(texy, url = nil, label = nil)
            self.modifier = Modifier.new(texy)

            url = url.to_s
            url = url[1..-2] if url.length > 1 && (url[0] == ?' || url[0] == ?")

            self.url = url.strip
            self.label = label.strip if label
        end
    end



    # Html tag anchor
    class LinkElement < InlineTagElement
        attr_accessor :link

        def initialize(texy)
            super
            self.link = Url.new(texy)
        end

        def set_link(url)
            link.set(url, texy.link_module.root)
        end

        def set_link_raw(link, text = '')
            if link[0] == ?[ && link[1] != ?*
                el_ref = texy.link_module.reference(link[1..-2])

                if el_ref
                    self.modifier = el_ref.modifier.dup
                    link = el_ref.url + el_ref.query
                    link.gsub!('%s', CGI.escape(Texy.wash(text)))
                else
                    set_link(link[1..-2])
                    return
                end
            end

            if link.length > 1 && link[0..1] == '[*'
                el_image = ImageElement.new(texy)
                el_image.set_images_raw(link[2..-3])
                el_image.require_link_image

                self.link = el_image.link_image.dup
                return
            end

            set_link(link)
        end



        protected
            def generate_tags(tags)
                return if link.as_url.empty? # dest URL is required

                attrs = modifier.attrs_of('a')
                texy.summary[:links] << attrs['href'] = link.as_url

                # rel="nofollow"
                nofollow_class = modifier.unfiltered_classes.include?('nofollow')

                if link.absolute? && (texy.link_module.force_no_follow || nofollow_class)
                    attrs['rel'] = attrs['rel'] ? "#{attrs['rel']} nofollow" : 'nofollow'
                end

                attrs['id'] = modifier.id
                attrs['title'] = modifier.title
                attrs['class'] = modifier.classes
                attrs['style'] = modifier.styles

                attrs['class'].delete('nofollow') if nofollow_class

                # popup on click
                if modifier.unfiltered_classes.include?('popup')
                    attrs['class'].delete('popup')
                    attrs['onclick'] = texy.link_module.popup_on_click
                end

                # email on click
                attrs['onclick'] = texy.link_module.email_on_click if link.email?

                # image on click
                attrs['onclick'] = texy.link_module.image_on_click if link.image?

                tags << ['a', attrs]
            end
    end



    # Html element anchor (with content)
    class LinkRefElement < TextualElement
        attr_accessor :ref_name

        @@callstack = {}

        def initialize(texy)
            super
            self.content_type = CONTENT_TEXTUAL
        end

        def set_link(ref_raw)
            self.ref_name = ref_raw[1..-2]
            low_name = ref_name.downcase # watch out for utf8!

            # prevent cycling
            return false if @@callstack[low_name]
            return false unless el_ref = texy.link_module.reference(ref_name)

            el_link = LinkElement.new(texy)
            el_link.set_link_raw(ref_raw)

            if el_ref.label
                @@callstack[low_name] = true
                parse(el_ref.label)
                @@callstack.delete(low_name)
            else
                set_content(el_link.link.as_textual, true)
            end

            set_content(append_child(el_link, content), true)
        end
    end
end