class Texy
    module Modules

        # Images module class
        class Image < Base
            # Proc that will be called with newly created element
            attr_accessor :handler

            # options

            # root of relative images (http)
            attr_accessor :root
            # root of linked images (http)
            attr_accessor :linked_root
            # physical location on server
            attr_accessor :root_prefix
            # left-floated image class
            attr_accessor :left_class
            # right-floated image class
            attr_accessor :right_class
            # default image alternative text
            attr_accessor :default_alt



            def initialize(texy)
                super

                self.root = 'images/'
                self.linked_root = 'images/'
                self.root_prefix = ''
                self.left_class = nil
                self.right_class = nil
                self.default_alt = ''

#                 if (isset($_SERVER['SCRIPT_NAME'])) {
#                     $this->rootPrefix = dirname($_SERVER['SCRIPT_NAME']).'/'; // physical location on server
#                 }
            end


            # Module initialization.
            def init
                # [*image*]:LINK    where LINK is:   url | [ref] | [*image*]
                texy.register_line_pattern(method(:process_line), /#{PATTERN_IMAGE}#{PATTERN_LINK_N}??()/)
            end



            # Add new named image
            def add_reference(name, obj)
                texy.add_reference("*#{name}*", obj)
            end

            # Receive new named link. If not exists, try call user function to create one.
            def reference(name)
                el = texy.reference("*#{name}*")
                if el.kind_of?(ImageReference)
                    el
                else
                    false
                end
            end



            # Preprocessing
            def pre_process(text)
                # [*image*]: urls .(title)[class]{style}
                text.gsub(/^\[\*([^\n]+)\*\]:\ +(.+?)\ *#{PATTERN_MODIFIER}?()/) do
                    el_ref = ImageReference.new(texy, $2)
                    el_ref.modifier.set_properties($3, $4, $5)

                    add_reference($1, el_ref)
                    ''
                end
            end



            # Callback function: [* small.jpg | small-over.jpg | big.jpg .(alternative text)[class]{style}>]:LINK
            def process_line(parser, matches)
                return '' unless allowed

                m_urls, m_link = matches.values_at(1, 6)

                el_image = ImageElement.new(texy)
                el_image.set_images_raw(m_urls)
                el_image.modifier.set_properties(*matches[2..5])

                if m_link
                    el_link = LinkElement.new(texy)

                    if m_link == ':'
                        el_image.require_link_image
                        el_link.link = el_image.link_image.dup
                    else
                        el_link.set_link_raw(m_link)
                    end

                    parser.element.append_child(el_link, parser.element.append_child(el_image))
                else
                    if handler
                        return '' unless handler.call(el_image)
                    end

                    parser.element.append_child(el_image)
                end
            end
        end
    end



    class ImageReference
        attr_accessor :urls
        attr_accessor :modifier

        def initialize(texy, urls = nil)
            self.modifier = Modifier.new(texy)
            self.urls = urls
        end
    end



    # Html element image
    class ImageElement < HtmlElement
        attr_accessor :image
        attr_accessor :over_image
        attr_accessor :link_image

        attr_accessor :width, :height

        def initialize(texy)
            super
            self.image = Url.new(texy)
            self.over_image = Url.new(texy)
            self.link_image = Url.new(texy)
        end

        def set_images(url = nil, url_over = nil, url_link = nil)
            image.set(url, texy.image_module.root, true)
            over_image.set(url_over, texy.image_module.root, true)
            link_image.set(url_link, texy.image_module.linked_root, true)
        end

        def set_size(width, height)
            self.width = width.to_i.abs
            self.height = height.to_i.abs
        end

        def set_images_raw(urls)
            el_ref = texy.image_module.reference(urls.strip)

            if el_ref
                urls = el_ref.urls
                self.modifier = el_ref.modifier.dup
            end

            urls = urls.split('|')

            # dimensions
            if match_data = /^(.*?)\ (?:(\d+)|\?)\ *x\ *(?:(\d+)|\?)\ *()/.match(urls[0])
                urls[0] = match_data[1]
                set_size(match_data[2], match_data[3])
            end

            set_images(*urls)
        end



        protected
            def generate_tags(tags)
                return if (image_url = image.as_url).empty? # image URL is required

                # classes & styles
                attrs = modifier.attrs_of('img')
                attrs['class'] = modifier.classes
                attrs['style'] = modifier.styles
                attrs['id'] = modifier.id

                if modifier.h_align == :left
                    if texy.image_module.left_class
                        attrs['class'] << texy.image_module.left_class
                    else
                        attrs['style']['float'] = 'left'
                    end
                elsif modifier.h_align == :right
                    if texy.image_module.right_class
                        attrs['class'] << texy.image_module.right_class
                    else
                        attrs['style']['float'] = 'right'
                    end
                end

                attrs['style']['vertical-align'] = modifier.v_align.to_s if modifier.v_align

                # width x height generate
                require_size

                attrs['width'] = width if width
                attrs['height'] = height if height

                # attribute generate
                texy.summary[:images] << attrs['src'] = image_url

                # onmouseover actions generate
                unless (over_url = over_image.as_url).empty?
                    attrs['onmouseover'] = "this.src=\"#{over_url}\""
                    attrs['onmouseout'] = "this.src=\"#{image.as_url}\""

                    texy.summary[:preload] << over_url
                end

                # alternative text generate
                attrs['alt'] = modifier.title || texy.image_module.default_alt

                tags << ['img', attrs]
            end

            def require_size
                return if width
                return unless defined? RMagick

#                 $file = $this->texy->imageModule->rootPrefix . '/' . $this->image->asURL();
#                 if (!is_file($file)) return FALSE;
#
#                 $size = getImageSize($file);
#                 if (!is_array($size)) return FALSE;
#
#                 $this->setSize($size[0], $size[1]);
            end

        public
            def require_link_image
                link_image.set(image.value, texy.image_module.linked_root, true) if link_image.as_url.empty?
            end
    end
end