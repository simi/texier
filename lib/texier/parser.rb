# 
# Copyright (c) 2008 Adam Ciganek <adam.ciganek@gmail.com>
# 
# This file is part of Texier.
# 
# Texier is free software: you can redistribute it and/or modify it under the
# terms of the GNU General Public License version 2 as published by the Free
# Software Foundation.
# 
# Texier is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along with
# Texier. If not, see <http://www.gnu.org/licenses/>.
# 
# For more information please visit http://code.google.com/p/texier/
# 



# This module contains classes to construct parsers. It is loosely based on the
# theory of Parsing Expression Grammar (PEG, see this wikipedia article for more
# details: http://en.wikipedia.org/wiki/Parsing_expression_grammar).
# 
# You construct the parser from basic components, called expressions. Every
# expression is a standalone parser, but to create complex parsers, you have to
# combine several expressions. For example, to create parser that parses string
# "foo" or string "bar", you do this:
# 
#   parser = e('foo') | e('bar')
# 
# The +e+ method turns a string into string *e*xpression and | operator combines
# the two expression into new one - the choice expression. You then parse a string
# like this:
# 
#   result = parser.parse('foo')
# 
# So the parser is constructed using natural syntax that resembles the way how
# formal grammars are denoted (EBNF and the like.). Or kind of :)
# 
# There are various classes of parsing expression. More information can be found
# in their documentation. I recomend starting with Texier::Expression class.

require 'strscan'

# OPTIMIZE: using packrat parsing.
require 'parser/expression'

require 'parser/everything_up_to'
require 'parser/choice'
require 'parser/indented'
require 'parser/map'
require 'parser/maybe'
require 'parser/negative_lookahead'
require 'parser/positive_lookahead'
require 'parser/regexp'
require 'parser/repetition'
require 'parser/sequence'
require 'parser/string'

require 'parser/lazy_sequence'
