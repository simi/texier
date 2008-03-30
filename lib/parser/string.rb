module Texier::Parser
  # Expression that matches a string.
  class String < Expression
    def initialize(string = '')
      @string = string
    end

    def parse_scanner(scanner)
      if scanner.peek(@string.length) == @string
        scanner.pos += @string.length
        [@string]
      else
        nil
      end
    end
  end
end