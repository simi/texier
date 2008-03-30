class Texier::Parser
  # Ordered choice.
  class Choice < Expression
    attr_reader :expressions

    def initialize(*expressions)
      @expressions = expressions.map do |expression|
        create(expression)
      end
    end

    def parse(scanner)
      @expressions.each do |expression|
        if result = expression.parse(scanner)
          return result
        end
      end

      nil
    end

    def << (expression)
      @expressions << expression
    end
  end
  
  module Generators
    # Create empty expression that never matches anything. It is actualy Choice,
    # so other expression can be added to it later using << operator.
    # 
    # TODO: rename to nothing, create another expression called empty that matches
    # empty string
    def empty
      Choice.new
    end
  end
end