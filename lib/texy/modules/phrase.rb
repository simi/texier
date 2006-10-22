class Texy
    module Modules

        # Phrases module class
        #
        #   **strong**
        #   *emphasis*
        #   ***strong+emphasis***
        #   ^^superscript^^
        #   __subscript__
        #   ++inserted++
        #   --deleted--
        #   ~~cite~~
        #   "span"
        #   ~span~
        #   `....`
        #   ``....``
        #
        class Phrase < Base
            # Proc that will be called with newly created element
            attr_accessor :code_handler
            attr_accessor :handler

            def initialize(texy)
                super
                self.allowed = {
                    '***' => 'strong em',
                    '**' => 'strong',
                    '*' => 'em',
                    '++' => 'ins',
                    '--' => 'del',
                    '^^' => 'sup',
                    '__' => 'sub',
                    '"' => 'span',
                    '~' => 'span',
                    '~~' => 'cite',
                    '""()'=> 'acronym',
                    '()' => 'acronym',
                    '`' => 'code',
                    '``' => ''
                }
            end

            # Module initialization.
            def init
                # (rane) ruby does not support lookbehinds, so i had to improvise a bit here...


                # strong & em speciality *** ... *** !!! its not good!
                if allowed['***']
                    texy.register_line_pattern(
                        proc {|p, m| process_phrase(p, m, allowed['***'])},
                        /\*\*\*(?!\ |\*)(.+?[^\ \*])#{PATTERN_MODIFIER}?\*\*\*(?!\*)()#{PATTERN_LINK}??()/
                    )
                end

                # **strong**
                if allowed['**']
                    texy.register_line_pattern(
                        proc {|p, m| process_phrase(p, m, allowed['**'])},
                        /\*\*(?!\ |\*)(.+?[^\ \*])#{PATTERN_MODIFIER}?\*\*(?!\*)#{PATTERN_LINK}??()/
                    )
                end

                # *emphasis*
                if allowed['*']
                    texy.register_line_pattern(
                        proc {|p, m| process_phrase(p, m, allowed['*'])},
                        /\*(?!\ |\*)(.+?[^\ \*])#{PATTERN_MODIFIER}?\*(?!\*)#{PATTERN_LINK}?()/
                    )
                end

                # ++inserted++
                if allowed['++']
                    texy.register_line_pattern(
                        proc {|p, m| process_phrase(p, m, allowed['++'])},
                        /\+\+(?!\ |\+)(.+?[^\ \+])#{PATTERN_MODIFIER}?\+\+(?!\+)()/
                    )
                end

                # --deleted--
                if allowed['--']
                    texy.register_line_pattern(
                        proc {|p, m| process_phrase(p, m, allowed['--'])},
                        /\-\-(?!\ |\-)(.+?[^\ \-])#{PATTERN_MODIFIER}?\-\-(?!\-)()/
                    )
                end

                # ^^superscript^^
                if allowed['^^']
                    texy.register_line_pattern(
                        proc {|p, m| process_phrase(p, m, allowed['^^'])},
                        /\^\^(?!\ |\^)(.+?[^\ \^])#{PATTERN_MODIFIER}?\^\^(?!\^)()/
                    )
                end

                # __subscript__
                if allowed['__']
                    texy.register_line_pattern(
                        proc {|p, m| process_phrase(p, m, allowed['__'])},
                        /__(?!\ |_)(.+?[^\ _])#{PATTERN_MODIFIER}?__(?!_)()/
                    )
                end

                # "span"
                if allowed['"']
                    texy.register_line_pattern(
                        proc {|p, m| process_phrase(p, m, allowed['"'])},
                        /\"(?!\ )([^"]+?[^\ ])#{PATTERN_MODIFIER}?"(?!")#{PATTERN_LINK}?()/
                    )
                end

                # ~alternative span~
                if allowed['~']
                    texy.register_line_pattern(
                        proc {|p, m| process_phrase(p, m, allowed['~'])},
                        /~(?!\ )([^~]+?[^\ ])#{PATTERN_MODIFIER}?~(?!~)#{PATTERN_LINK}?()/
                    )
                end

                # ~~cite~~
                if allowed['~~']
                    texy.register_line_pattern(
                        proc {|p, m| process_phrase(p, m, allowed['~~'])},
                        /~~(?!\ |~)(.+?[^\ ~])#{PATTERN_MODIFIER}?~~(?!~)#{PATTERN_LINK}?()/
                    )
                end

                if allowed['""()']
                    # acronym/abbr "et al."((and others))
                    texy.register_line_pattern(
                        proc {|p, m| process_phrase(p, m, allowed['""()'])},
                        /"(?!\ )([^"]+?[^\ ])#{PATTERN_MODIFIER}?"(?!")\(\((.+?)\)\)()/
                    )
                end

                if allowed['()']
                    # acronym/abbr NATO((North Atlantic Treaty Organisation))
                    texy.register_line_pattern(
                        proc {|p, m| process_phrase(p, m, allowed['()'])},
                        /(\w{2,}?)()()()\(\((.+?)\)\)/
                    )
                end

                # ``protected`` (experimental, dont use)
                if allowed['``']
                    texy.register_line_pattern(
                        method(:process_protect),
                        /``(\S[^#{HASH}]*?[^\ ])``()/
                    )
                end

                # `code`
                if allowed['`']
                    texy.register_line_pattern(
                        method(:process_code),
                        /`(\S[^#{HASH}]*?[^\ ])#{PATTERN_MODIFIER}?`()/
                    )
                end

                # `=samp
                texy.register_block_pattern(
                    method(:process_block),
                    /^`=(none|code|kbd|samp|var|span)$/i
                )
            end

            # Callback function: **.... .(title)[class]{style}**
            def process_phrase(parser, matches, tags)
                match, m_content, m_link = matches.values_at(0, 1, 5)
                mods = matches[2..4]

                if m_content.to_s.empty?
                    match_data = /^(.)+?(.+?)#{PATTERN_MODIFIER}?\1+()/.match(match)
                    match, m_delim, m_content, m_link = match_data.to_a.values_at(0, 1, 2, 6)
                    mods = match_data.to_a[3..5]
                end

                tags = '' if (tags == 'span') && m_link # eliminate unnecesary spans, use <a ..> instead
                return match if (tags == 'span') && !mods.any? # don't use unnecesary spans...

                el = nil

                tags.split(' ').reverse.each do |tag|
                    el = InlineTagElement.new(texy)
                    el.tag = tag

                    if tag == 'acronym' || tag == 'abbr'
                        el.modifier.title = m_link
                        m_link = ''
                    end

                    if handler
                        return '' unless handler.call(el, tags)
                    end

                    m_content = parser.element.append_child(el, m_content)
                end

                if m_link
                    el = LinkElement.new(texy)
                    el.set_link_raw(m_link, m_content)

                    m_content = parser.element.append_child(el, m_content)
                end

                el.modifier.set_properties(*mods) if el

                m_content
            end

            # Callback function `=code
            def process_block(parser, matches)
                # (rane) wtf?

                allowed['`'] = matches[1].downcase
                allowed['`'] = '' if allowed['`'] == 'none'
            end

            # Callback function: `.... .(title)[class]{style}`
            def process_code(parser, matches)
                m_content = matches[1]

                el = TextualElement.new(texy)
                el.modifier.set_properties(*matches[2..4])
                el.content_type = DomElement::CONTENT_TEXTUAL
                el.set_content(m_content, false) # content isn't html safe
                el.tag = allowed['`']

                if code_handler
                    return '' unless code_handler.call(el, 'code')
                end

                el.safe_content # ensure that content is HTML safe

                parser.element.append_child(el)
            end

            # User callback - PROTECT PHRASE
            def process_protect(parser, matches, html_safe = false)
                m_content = matches[1]

                el = TextualElement.new(texy)
                el.content_type = TexyDomElement::CONTENT_TEXTUAL;
                el.set_content(Texy.freeze_spaces(m_content), is_html_safe)

                parser.element.append_child(el)
            end
        end
    end
end