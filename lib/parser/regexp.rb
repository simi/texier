module Texier::Parser
  # Expression that matches when regexp matches.
  class Regexp < Expression
    def initialize(regexp = //)
      @regexp = regexp
    end

    def parse_scanner(scanner)
      result = scanner.scan(@regexp)
      result ? [result] : nil
    end
  end
  
  module Generators
    # Expression that matches end of line.
    def eol
      e(/$/).skip
    end
  end
end