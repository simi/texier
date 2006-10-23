class Texy

    # Modifier processor.
    #
    # Modifier is text like .(title)[class1 class2 #id]{color: red}>^
    #   .         starts with dot
    #   (...)     title or alt modifier
    #   [...]     classes or ID modifier
    #   {...}     inner style modifier
    #   < > <> =  horizontal align modifier
    #   ^ - _     vertical align modifier
    #
    class Modifier
        attr_accessor :id
        attr_accessor :classes
        attr_accessor :unfiltered_classes
        attr_accessor :styles
        attr_accessor :unfiltered_styles
        attr_accessor :unfiltered_attrs
        attr_accessor :h_align
        attr_accessor :v_align
        attr_accessor :title



        def initialize(texy)
            @texy = texy # parent Texy! object

            self.classes = []
            self.unfiltered_classes = []
            self.styles = {}
            self.unfiltered_styles = {}
            self.unfiltered_attrs = {}
        end

        def set_properties(*args)
            classes = ''
            styles = ''

            args.each do |arg|
                next if arg.to_s.empty?

                arg_x = arg[1..-2].strip

                case arg[0]
                    when ?{ then styles += arg_x + ';'
                    when ?( then self.title = arg_x
                    when ?[ then classes += ' ' +  arg_x
                    when ?^ then self.v_align = :top
                    when ?- then self.v_align = :middle
                    when ?_ then self.v_align = :bottom
                    when ?= then self.h_align = :justify
                    when ?> then self.h_align = :right
                    when ?< then self.h_align = if arg == '<>' then :center else :left end
                end
            end

            parse_styles styles
            parse_classes classes
        end

        def attrs_of(tag)
            return unfiltered_attrs if @texy.allowed_tags == :all

            attrs = {}

            if @texy.allowed_tags.kind_of?(Hash) && @texy.allowed_tags[tag]
                allowed_attrs = @texy.allowed_tags[tag]

                return unfiltered_attrs if allowed_attrs == :all

                if allowed_attrs.kind_of?(Array) && !allowed_attrs.empty?
                    unfiltered_attrs.each do |key, value|
                        attrs[key] = value if allowed_attrs.include?(key)
                    end
                end
            end

            attrs
        end

        def clear
            self.id = nil
            self.classes = []
            self.unfiltered_classes = []
            self.styles = {}
            self.unfiltered_styles = {}
            self.unfiltered_attrs = {}
            self.h_align = nil
            self.v_align = nil
            self.title = nil
        end



        # (rane) In original code, there was method copyFrom, but i think dup can be used instead (clone in php)



        def parse_classes(string)
            return if string.to_s.empty?

            # little speed-up trick
            tmp = if @texy.allowed_classes.kind_of? Array
                @texy.allowed_classes.to_hash.invert
            else
                {}
            end

            string.gsub('#', ' #').split(' ').each do |value|
                next if value.empty?

                if value[0] == ?#
                    # (rane) Original code had little wtf here (imho): It assigned the value
                    # to  classes array under the key "id" and then in the method setProperties()
                    # extracted it back and assigned to attribute id.
                    self.id = value[1..-1]
                else
                    unfiltered_classes << value
                    classes << value if @texy.allowed_classes == :all || tmp[value]
                end
            end
        end

        def parse_styles(string)
            return if string.to_s.empty?

            # little speed-up trick
            tmp = if @texy.allowed_styles.kind_of? Array
                @texy.allowed_styles.to_hash.invert
            else
                {}
            end

            string.split(';').each do |value|
                pair = "#{value}:".split(':')
                property = pair[0].strip.downcase
                value = pair[1].strip

                next if property.empty?

                if Html::ACCEPTED_ATTRS[property] # attribute
                    unfiltered_attrs[property] = value
                else # style
                    unfiltered_styles[property] = value

                    styles[property] = value if @texy.allowed_styles == :all || tmp[property]
                end
            end
        end
    end
end