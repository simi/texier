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
                @pairs = {
                    /([^"\w])"(?!\ |")(.+?)([^\ "])"(?!")()/ => "\\1#{double_quotes[0]}\\2#{double_quotes[1]}\\3", # double ""
                    /([^'\w])'(?!\ |')(.+?)([^\ '])'(?!')()/ => "\\1#{single_quotes[0]}\\2#{single_quotes[1]}\\3", # single ''
                    /(\S|^) ?\.{3}/ => '\1&#8230;', # ellipsis ...
                    /(\d| )-(\d| )/ => "\\1#{dash}\\2", # en dash -
                    /,-/ => ",#{dash}", # en dash ,-
                    /([^\d])(\d{1,2}\.)\ (\d{1,2}\.)\ (\d\d)/ => '\1\2&#160;\3&#160;\4', # date 23. 1. 1978
                    /([^\d])(\d{1,2}\.)\ (\d{1,2}\.)/ => '\1\2&#160;\3', # date 23. 1.
                    /\ --\ / => " #{dash} ", # en dash --
                    /\ -&gt;\ / => ' &#8594; ', # right arrow ->
                    /\ &lt;-\ / => ' &#8592; ', # left arrow ->
                    /\ &lt;-&gt;\ / => ' &#8596; ', # left right arrow <->
                    /(\d+)\ ?x\ ?(\d+)\ ?x\ ?(\d+)/ => '\1&#215;\2&#215;\3', # dimension sign x
                    /(\d+) ?x ?(\d+)/ => '\1&#215;\2', # dimension sign x
                    /(\d)x(?= |,|.|$)/ => '\1&#215;', # 10x
                    /(\S ?)\(TM\)/i => '\1&#8482;', # trademark  (TM)
                    /(\S ?)\(R\)/i => '\1&#174;', # registered (R)
                    /\(C\)( ?\S)/i => '&#169;\1', # copyright  (C)
                    /(\d{1,3})\ (\d{3})\ (\d{3})\ (\d{3})/ => '\1&#160;\2&#160;\3&#160;\4', # (phone) number 1 123 123 123
                    /(\d{1,3})\ (\d{3})\ (\d{3})/ => '\1&#160;\2&#160;\3', # (phone) number 1 123 123
                    /(\d{1,3})\ (\d{3})/ => '\1&#160;\2', # number 1 123


                    /([^\ \.,\-\+])(\d+)([#{HASH_NC}]*)\ ([#{HASH_NC}]*)([#{CHAR}])/ =>
                        '\1\2\3&#160;\4\5', # space between number and word

                    # (rane) TODO: the preposition list should be configurable
                    /(^|[^0-9#{CHAR}])([#{HASH_NC}]*)([ksvzouiKSVZOUIA])([#{HASH_NC}]*)\ ([#{HASH_NC}]*)([0-9#{CHAR}])/ =>
                        '\1\2\3\4&#160;\5\6', # space between preposition and word
                }
            end

            def line_post_process(text)
                return text unless allowed

                @pairs.each do |from, to|
                    text.gsub!(from, to)
                end

                text
            end
        end
    end
end