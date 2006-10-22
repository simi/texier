class Texy
    module Modules

        # Image with description module class
        class ImageDesc < Base

            # Proc that will be called with newly created element
            attr_accessor :handler

            # non-floated box class
            attr_accessor :box_class
            # left-floated box class
            attr_accessor :left_class

            # right-floated box class
            attr_accessor :right_class

            def initialize(texy)
                super
                self.box_class = 'image'
                self.left_class = 'image left'
                self.right_class = 'image right'
            end

            # Module initialization.
            def init
                if texy.image_module.allowed
                    texy.register_block_pattern(
                        method(:process_block),
                        /^#{PATTERN_IMAGE}#{PATTERN_LINK_N}?\ +\*\*\*\ +(.*?)#{PATTERN_MODIFIER}?()$/
                    )
                end
            end

            # Callback function (for blocks)
            #
            #    [*image*]:link *** .... .(title)[class]{style}>
            #
            def process_block(parser, matches)
                m_urls, m_link, m_content = matches.values_at(1, 6, 7)
                img_mods = matches[2..5]
                mods = matches[8..11]

                el = ImageDescElement.new(texy)
                el.modifier.set_properties(*mods)

                el_image = ImageElement.new(texy)
                el_image.set_images_raw(m_urls)
                el_image.modifier.set_properties(*img_mods)

                el.modifier.h_align = el_image.modifier.h_align
                el_image.modifier.h_align = nil

                content = el.append_child(el_image)

                if m_link
                    el_link = LinkElement.new(texy)
                    if m_link == ':'
                        el_image.require_link_image
                        el_link.link = el_image.link_image.dup
                    else
                        el_link.set_link_raw(m_link)
                    end

                    content = el.append_child(el_link, content)
                end

                el_desc = GenericBlockElement.new(texy)
                el_desc.parse(m_content.lstrip)
                content += el.append_child(el_desc)
                el.set_content(content, true)

                if handler
                    return unless handler.call(el)
                end

                parser.element.append_child(el)
            end
        end
    end



    # Html element image (with description)
    class ImageDescElement < TextualElement
        protected
            def generate_tags(tags)
                attrs = modifier.attrs_of('div')
                attrs['class'] = modifier.classes;
                attrs['style'] = modifier.styles;
                attrs['id'] = modifier.id;

                if modifier.h_align == :left
                    attrs['class'] << texy.image_desc_module.left_class
                elsif modifier.h_align == :right
                    attrs['class'] << texy.image_desc_module.right_class
                elsif texy.image_desc_module.box_class
                    attrs['class'] << texy.image_desc_module.box_class
                end

                tags << ['div', attrs]
            end
    end
end