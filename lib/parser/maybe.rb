module Texier::Parser
  # Expression is optional.
  class Maybe < Expression
    def initialize(expression)
      @expression = e(expression)
    end

    def parse_scanner(scanner)
      @expression.parse_scanner(scanner) || [nil]
    end
  end
  
  class Expression
    def maybe
      Maybe.new(self)
    end
  end
end