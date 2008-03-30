require 'strscan'

module Texier
  class Parser
  end
end

require 'parser/expression'

require 'parser/everything_up_to'
require 'parser/choice'
require 'parser/indented'
require 'parser/mapper'
require 'parser/negative_lookahead'
require 'parser/optional'
require 'parser/positive_lookahead'
require 'parser/regexp'
require 'parser/repetition'
require 'parser/repetition_with_separator'
require 'parser/repetition_up_to'
require 'parser/sequence'
require 'parser/string'


module Texier
  # Parser generator based on the theory of Parsing Expression Grammars (PEG).
  # 
  # TODO: describe it in more detail.
  # 
  # OPTIMIZE: using packrat parsing.
  class Parser
    def initialize
      @expressions = {}
    end

    # Access to exported expressions.
    def [](name)
      raise Error, "Expression \"#{name}\" not defined." unless @expressions.has_key?(name)
      @expressions[name]
    end

    # Add expression to exported expressions
    def []=(name, value)
      @expressions[name] = value
    end

    def has_expression?(name)
      @expressions.has_key?(name)
    end

    # Parse the string.
    def parse(input)
      raise Error, 'Starting expression not defined.' unless @expressions[:document]

      scanner = StringScanner.new(input)
      @expressions[:document].parse(scanner)
    end

    # Helper method to generate various types of parsing expressions.
    module Generators
      # Expression that matches text inside quotes.
      def quoted_text(opening, closing = opening)
        discard(opening) & everything_up_to(discard(closing))
      end

      # Match expression, but discard the result.
      def discard(e)
        expression(e).map {[]}
      end
    end
  end
end
