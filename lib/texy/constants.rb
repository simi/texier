class Texy
    # Regular expressions

    #     international characters 'A-Za-z\x86-\xff'
    #     unicode                  'A-Za-z\x86-\x{ffff}'
    #     numbers                  0-9
    #     spaces                   \n\r\t\x32
    #     control                  \x00 - \x31  (without spaces)
    #     others                   !"#$%&'()*+,-./:;<=>?@[\]^_`{|}~


    # character classes
    CHAR = 'A-Za-z\x86-\xff' # International char - use instead of \w
    CHAR_UTF = 'A-Za-z\x86-\x{ffff}'

    # hashing meta-charakters
    HASH = "\x15-\x1F" # Any hash char
    HASH_SPACES = "\x15-\x18" # Hashed space
    HASH_NC = "\x19\x1B-\x1F" # Hashed tag or element (without content)
    HASH_WC = "\x1A-\x1F" # Hashed tag or element (with content)


    # links
    PATTERN_LINK_REF = /\[[^\[\]\*\n#{HASH}]+?\]/ # reference [refName]
    PATTERN_LINK_IMAGE = /\[\*[^\n#{HASH}]+\*\]/ # [* ... *]
    PATTERN_LINK_URL = /(?:\[[^\]\n]+\]|(?!\[)[^\s#{HASH}]*?[^:);,.!?\s#{HASH}])/ # any url
    PATTERN_LINK = /(?::(#{PATTERN_LINK_URL}))/ # any link
    PATTERN_LINK_N = /(?::(#{PATTERN_LINK_URL}|:))/ # any link (also unstated)
    PATTERN_EMAIL = /[a-z0-9.+_-]+@[a-z0-9.+_-]{2,}\.[a-z]{2,}/ # name@exaple.com


    # (rane) In these PATTERN_MODIFIER_X, There was
    #   (?<= |^)\.
    # instead of
    #   (?:\ \.|^\.)
    # but ruby does not support lookbehinds. This should be equivalent.

    # modifier .(title)[class]{style}
    PATTERN_MODIFIER = /(?:\ *(?:\ \.|^\.)(\([^\n\)]+\)|\[[^\n\]]+\]|\{[^\n\}]+\})(\([^\n\)]+\)|\[[^\n\]]+\]|\{[^\n\}]+\})??(\([^\n\)]+\)|\[[^\n\]]+\]|\{[^\n\}]+\})??)/

    # modifier .(title)[class]{style}<>
    PATTERN_MODIFIER_H = /(?:\ *(?:\ \.|^\.)(\([^\n\)]+\)|\[[^\n\]]+\]|\{[^\n\}]+\}|(?:<>|>|=|<))(\([^\n\)]+\)|\[[^\n\]]+\]|\{[^\n\}]+\}|(?:<>|>|=|<))??(\([^\n\)]+\)|\[[^\n\]]+\]|\{[^\n\}]+\}|(?:<>|>|=|<))??(\([^\n\)]+\)|\[[^\n\]]+\]|\{[^\n\}]+\}|(?:<>|>|=|<))??)/

    # modifier .(title)[class]{style}<>^
    PATTERN_MODIFIER_HV = /(?:\ *(?:\ \.|^\.)(\([^\n\)]+\)|\[[^\n\]]+\]|\{[^\n\}]+\}|(?:<>|>|=|<)|(?:\^|\-|\_))(\([^\n\)]+\)|\[[^\n\]]+\]|\{[^\n\}]+\}|(?:<>|>|=|<)|(?:\^|\-|\_))??(\([^\n\)]+\)|\[[^\n\]]+\]|\{[^\n\}]+\}|(?:<>|>|=|<)|(?:\^|\-|\_))??(\([^\n\)]+\)|\[[^\n\]]+\]|\{[^\n\}]+\}|(?:<>|>|=|<)|(?:\^|\-|\_))??(\([^\n\)]+\)|\[[^\n\]]+\]|\{[^\n\}]+\}|(?:<>|>|=|<)|(?:\^|\-|\_))??)/

    # images [* urls .(title)[class]{style} >]
    PATTERN_IMAGE = /\[\*([^\n#{HASH}]+)#{PATTERN_MODIFIER}? *(\*|>|<)\]/
end