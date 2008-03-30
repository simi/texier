class Texier::Parser
  class PositiveLookahead < Expression
    def initialize(expression)
      @expression = expression
    end

    def parse(scanner)
      @expression.peek(scanner) ? [] : nil
    end
  end
end