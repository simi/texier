class Texier::Parser
  # Expression is optional.
  class Optional < Expression
    def initialize(expression)
      @expression = create(expression)
    end

    def parse(scanner)
      @expression.parse(scanner) || [nil]
    end
  end
  
  module Generators
    def optional(e)
      Optional.new(e)
    end
  end
end