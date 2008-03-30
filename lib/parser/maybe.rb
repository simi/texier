class Texier::Parser
  # Expression is optional.
  class Maybe < Expression
    def initialize(expression)
      @expression = create(expression)
    end

    def parse(scanner)
      @expression.parse(scanner) || [nil]
    end
  end
end