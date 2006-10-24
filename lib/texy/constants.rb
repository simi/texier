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
    # Regular expressions

    # hashing meta-charakters
    HASH = "\x15-\x1F" # Any hash char
    HASH_SPACES = "\x15-\x18" # Hashed space
    HASH_NC = "\x19\x1B-\x1F" # Hashed tag or element (without content)
    HASH_WC = "\x1A-\x1F" # Hashed tag or element (with content)

    # links
    PATTERN_LINK_REF = /\[[^\[\]\*\n#{HASH}]+?\]/ # reference [refName]
    PATTERN_LINK_IMAGE = /\[\*[^\n#{HASH}]+\*\]/ # [* ... *]
    PATTERN_LINK_URL = /(?:\[[^\]\n]+?\]|(?!\[)[^\s#{HASH}]*[^:\);,\.!\?\s#{HASH}])/ # any url
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
    PATTERN_IMAGE = /\[\*([^\n#{HASH}]+?)#{PATTERN_MODIFIER}?\ *(\*|>|<)\]/
end