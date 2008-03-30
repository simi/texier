require 'strscan'

# OPTIMIZE: using packrat parsing.
require 'parser/expression'

require 'parser/everything_up_to'
require 'parser/choice'
require 'parser/indented'
require 'parser/mapper'
require 'parser/maybe'
require 'parser/negative_lookahead'
require 'parser/positive_lookahead'
require 'parser/regexp'
require 'parser/repetition'
require 'parser/repetition_with_separator'
require 'parser/repetition_up_to'
require 'parser/sequence'
require 'parser/string'