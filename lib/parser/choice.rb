module Texier::Parser
  # Ordered choice.
  class Choice < Expression
    attr_reader :expressions

    def initialize(*expressions)
      @expressions = expressions.map(&method(:e))
    end

    def parse_scanner(scanner)
      @expressions.each do |expression|
        if result = expression.parse_scanner(scanner)
          return result
        end
      end

      nil
    end

    def << (expression)
      @expressions << expression
    end
  end
  
  class Expression
    def | (other)
      if other.is_a?(Choice)
        Choice.new(self, *other.expressions)
      else
        Choice.new(self, other)
      end
    end
  end
  
  module Generators
    # Create expression that never matches anything. It is actualy Choice,
    # so other expression can be added to it later using << operator.
    def nothing
      Choice.new
    end
  end
end