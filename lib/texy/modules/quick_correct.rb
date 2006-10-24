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
        # Automatic replacements module class
        class QuickCorrect < Base
            # options

            # left & right double quote (&bdquo; &ldquo;)
            attr_accessor :double_quotes

            # left & right single quote (&sbquo; &lsquo;)
            attr_accessor :single_quotes

            # dash (&ndash;)
            attr_accessor :dash

            def initialize(texy)
                super

                self.double_quotes = ['&#8222;', '&#8220;']
                self.single_quotes = ['&#8218;', '&#8216;']
                self.dash = '&#8211;'
            end

            # Module initialization.
            def init
                @pairs = [
                    # double ""
                    [/([^"\w]|^)"(?!\ |")(.+?[^\ "])"(?!")()/, "\\1#{double_quotes[0]}\\2#{double_quotes[1]}"],

                    # single ''
                    [/([^'\w]|^)'(?!\ |')(.+?[^\ '])'(?!')()/, "\\1#{single_quotes[0]}\\2#{single_quotes[1]}"],

                    # ellipsis ...
                    [/(\S|^)\ ?\.{3}/, '\1&#8230;'],

                    # en dash -
                    [/(\d| )-(\d| )/, "\\1#{dash}\\2"],

                    # en dash ,-
                    [/,-/, ",#{dash}"],

                    # date 23. 1. 1978
                    [/([^\d]|^)(\d{1,2}\.)\ (\d{1,2}\.)\ (\d\d)/, '\1\2&#160;\3&#160;\4'],

                    # date 23. 1.
                    [/([^\d]|^)(\d{1,2}\.)\ (\d{1,2}\.)/, '\1\2&#160;\3'],

                    # en dash --
                    [/\ --\ /, " #{dash} "],

                    # right arrow ->
                    [/\ -&gt;\ /, ' &#8594; '],

                    # left arrow ->
                    [/\ &lt;-\ /, ' &#8592; '],

                    # left right arrow <->
                    [/\ &lt;-&gt;\ /, ' &#8596; '],

                    # dimension sign x
                    [/(\d+)\ ?x\ ?(\d+)\ ?x\ ?(\d+)/, '\1&#215;\2&#215;\3'],

                    # dimension sign x
                    [/(\d+) ?x ?(\d+)/, '\1&#215;\2'],

                    # 10x
                    [/(\d)x(?= |,|.|$)/, '\1&#215;'],

                    # trademark  (TM)
                    [/(\S ?)\(TM\)/i, '\1&#8482;'],

                    # registered (R)
                    [/(\S ?)\(R\)/i, '\1&#174;'],

                    # copyright  (C)
                    [/\(C\)( ?\S)/i, '&#169;\1'],

                    # (phone) number 1 123 123 123
                    [/(\d{1,3})\ (\d{3})\ (\d{3})\ (\d{3})/, '\1&#160;\2&#160;\3&#160;\4'],

                    # (phone) number 1 123 123
                    [/(\d{1,3})\ (\d{3})\ (\d{3})/, '\1&#160;\2&#160;\3'],

                    # number 1 123
                    [/(\d{1,3})\ (\d{3})/, '\1&#160;\2'], # number 1 123

                    # space between number and word
                    [/([\ \.,\-\+]|^)(\d+)([#{HASH_NC}]*)\ ([#{HASH_NC}]*)(\w)/, '\1\2\3&#160;\4\5'],

                    # space between preposition and word
                    # (rane) TODO: the preposition list should be configurable
                    [/(^|[^0-9\w])([#{HASH_NC}]*)([ksvzouiKSVZOUIA])([#{HASH_NC}]*)\ ([#{HASH_NC}]*)([0-9\w])/,
                        '\1\2\3\4&#160;\5\6'],
                ]
            end

            def line_post_process(text)
                return text unless allowed

                @pairs.each do |(from, to)|
                    text.gsub!(from, to)
                end

                text
            end
        end
    end
end