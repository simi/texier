class Texier::Parser
  class NegativeLookahead < Expression
    def initialize(expression)
      @expression = expression
    end

    def parse(scanner)
      @expression.peek(scanner) ? nil : []
    end
  end
end