module Texier::Parser
  class PositiveLookahead < Expression
    def initialize(expression)
      @expression = expression
    end

    def parse_scanner(scanner)
      @expression.peek(scanner) ? [] : nil
    end
  end
  
  class Expression
    def +@
      PositiveLookahead.new(self)
    end
  end
end