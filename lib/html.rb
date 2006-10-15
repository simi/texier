require 'cgi'

class Texy
    class Html
        EMPTY_TAG = '/'

        # Block elements
        BLOCK = [
            'address', 'blockquote', 'caption', 'col', 'colgroup', 'dd', 'div', 'dl', 'dt', 'fieldset', 'form',
            'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'hr', 'iframe', 'legend', 'li', 'object', 'ol', 'p', 'param',
            'pre', 'table', 'tbody', 'td', 'tfoot', 'th', 'thead', 'tr', 'ul'
            #, 'embed'
        ].to_hash.invert.assign_to_all(:all) # I'm using little speedup trick: key lookup in hash is
                                             # much faster (O(1)), than value lookup in array (O(n)).

        # Inline elements
        INLINE = [
            'a', 'abbr', 'acronym', 'area', 'b', 'big', 'br', 'button', 'cite', 'code', 'del', 'dfn',
            'em', 'i', 'img', 'input', 'ins', 'kbd', 'label', 'map', 'noscript', 'optgroup', 'option', 'q',
            'samp', 'script', 'select', 'small', 'span', 'strong', 'sub', 'sup', 'textarea', 'tt', 'var'
        ].to_hash.invert.assign_to_all(:all)

        # All elements
        VALID = BLOCK.merge INLINE

        # Empty elements (ones without closing tag)
        EMPTY = ['img', 'hr', 'br', 'input', 'meta', 'area', 'base', 'col', 'link', 'param'].to_hash.invert

        # META = ['html', 'head', 'body', 'base', 'meta', 'link', 'title']

        ACCEPTED_ATTRS = [
            'abbr', 'accesskey', 'align', 'alt', 'archive', 'axis', 'bgcolor', 'cellpadding', 'cellspacing', 'char',
            'charoff', 'charset', 'cite', 'classid', 'codebase', 'codetype', 'colspan', 'compact', 'coords', 'data',
            'datetime', 'declare', 'dir', 'face', 'frame', 'headers', 'href', 'hreflang', 'hspace', 'ismap',
            'lang', 'longdesc', 'name', 'noshade', 'nowrap', 'onblur', 'onclick', 'ondblclick', 'onkeydown',
            'onkeypress', 'onkeyup', 'onmousedown', 'onmousemove', 'onmouseout', 'onmouseover', 'onmouseup', 'rel',
            'rev', 'rowspan', 'rules', 'scope', 'shape', 'size', 'span', 'src', 'standby', 'start', 'summary',
            'tabindex', 'target', 'title', 'type', 'usemap', 'valign', 'value', 'vspace'
        ].to_hash.invert



        # Like (PHP) htmlspecialchars, but can preserve entities
        #
        # Parameters:
        # +s+:: input string
        # +in_quotes+:: for using inside quotes?
        # +entity+:: preserve entities?
        #
        def self.html_chars(s, in_quotes = false, entity = false)
            s = CGI.escapeHTML(s)

            # Unescape double quotes to emulate PHP function htmlspecialchars
            # with second parameter set to ENT_NOQUOTES
            s.gsub!('&quot;', '"') unless in_quotes

            # preserve numeric entities?
            s.gsub!(/&amp;([a-zA-Z0-9]+|#x[0-9a-fA-F]+|#[0-9]+);/, '&$1;') if entity

            s
        end



        # Build string which represents (X)HTML opening tag
        #
        # Parameters:
        # +tags+:: array of arrays, where each array contains two elements: the name of tag and hash of it's
        #          attributes. If name id "/", it is empty tag.
        def self.opening_tags(tags)
            return '' if tags.empty?

            tags.inject('') do |result, (tag, attrs)|
                next if tag.empty?

                empty = EMPTY[tag] || attrs[EMPTY_TAG]
                attr_str = ''

                unless attrs.empty?
                    attrs.delete(EMPTY_TAG)

                    attrs.downcase_keys.each do |name, value|
                        if value.kind_of?(Hash) && name == 'style'
                            value = value.downcase_keys.inject([]) do |style, key_s, value_s|
                                style << "#{keys_s}:#{value_s}" unless key_s.empty? || value_s.empty?
                                style
                            end.join(';')
                        elsif value.kind_of?(Array)
                            value = value.uniq.join(' ')
                        end

                        next if value.to_s.empty?

                        value.strip!

                        # Freezed spaces will be preserved during reformating.
                        attr_str += %Q( #{html_chars(name)}="#{Texy.freeze_spaces(html_chars(value, true, true))}")
                    end
                end

                result + "<#{tag}#{attr_str}#{empty ? ' /' : ''}>"
            end
        end



        # Build string which represents (X)HTML closing tag
        def self.closing_tags(tags)
            return '' if tags.empty?

            tags.reverse.inject('') do |result, (tag, attrs)|
                next if tag.empty? || EMPTY[tag] || attrs[EMPTY_TAG]
                result + "</#{tag}>"
            end
        end
    end
end