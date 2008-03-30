module Texier::Parser
  class NegativeLookahead < Expression
    def initialize(expression)
      @expression = expression
    end

    def parse_scanner(scanner)
      @expression.peek(scanner) ? nil : []
    end
  end
  
  class Expression
    def -@
      NegativeLookahead.new(self)
    end
  end
end