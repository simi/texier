require 'uri'

class Texy

    # URL storage
    #
    # Analyse type of URL and convert it to valid URL or textual representation
    class Url

        ABSOLUTE = 1
        RELATIVE = 2
        EMAIL = 4
        IMAGE = 8

        attr_accessor :value

        # Creates a new Url object
        #
        # Parameters:
        #   texy:: association with root Texy object
        def initialize(texy)
            @texy =  texy
        end

        # Sets URL properties
        #
        # Parameters:
        #   value::     text written in document
        #   root::      root, for relative URL's
        #   is_image::  image indicator (user usage)
        def set(value, root = '', is_image = false)
            self.value = value.to_s.strip
            @root = root.gsub(/[\/\\]/, '') + '/' if root

            # will be completed on demand
            @url = nil

            # detect URL type
            if /^#{PATTERN_EMAIL}$/i =~ value # email
                @flags = EMAIL
            elsif /^(https?:\/\/|ftp:\/\/|www\.|ftp\.|\/)/i =~ value # absolute URL
                @flags = ABSOLUTE | (is_image ? IMAGE : 0)
            else # relative
                @flags = RELATIVE | (is_image ? IMAGE : 0)
            end
        end



        # Indicates whether URL is absolute
        def absolute?
            @flags & ABSOLUTE != 0
        end

        def relative?
            @flags & ABSOLUTE == 0
        end

        # Indicates whether URL is email address (mailto://)
        def email?
            @flags & EMAIL != 0
        end

        # Indicates whether URL is marked as 'image'
        def image?
            @flags & IMAGE != 0
        end



        # Returns URL formatted for HTML attributes etc.
        def as_url
            # output is cached
            return @url if @url
            return @url = value if value.empty?

            # email URL
            if email?
                # obfuscating against spam robots
                if @texy.obfuscate_email?
                    @url = 'mai'
                    s = "lto:#{value}"

                    s.each_byte do |i|
                        @url += "&##{i};"
                    end
                else
                    @url = "mailto:#{value}"
                end

                @url
            elsif absolute? # absolute URL
                lower = value.downcase

                # must begins with 'http://' or 'ftp://'
                if lower[0..3] == 'www.'
                    return @url = "http://#{value}"
                elsif lower[0..3] == 'ftp.'
                    return @url = "ftp://#{value}"
                end

                @url = value
            else # relative URL
                @url = @root + value
            end
        end

        # Returns textual representation of URL
        def as_textual
            if email?
                @texy.obfuscate_email? ? value.gsub('@', "&#160;(at)&#160;") : value
            elsif absolute?
                url = value
                lower = url.downcase

                if lower[0..4] == 'www.'
                    url = "none://#{url}"
                elsif lower[0..4] == 'ftp.'
                    url = "none://#{url}"
                end

                parts = URI.parse(url)
                return value unless parts

                res = ''

                if parts.scheme && parts.scheme != 'none'
                    res += parts.scheme + '://'
                end

                if parts.host
                    res += parts.host
                end

                if parts.path
                    res +=  (parts.path.length > 16 ? '/...' + parts.path.gsub(/^.*?(.{0,12})$/, '\1') : parts.path)
                end

                if parts.query
                    res += parts.query.length > 4 ? '?...' : "?#{parts.query}"
                elsif parts.fragment
                    res += parts.fragment.length > 4 ? '#...' : "##{parts.fragment}"
                end

                res
            else
                value
            end
        end
    end
end