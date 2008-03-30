module Texier::Parser
  # Sequence of expressions
  class Sequence < Expression
    attr_reader :expressions

    def initialize(*expressions)
      @expressions = expressions.map(&method(:e))
    end

    def parse_scanner(scanner)
      previous_pos = scanner.pos
      results = []

      @expressions.each do |expression|
        if result = expression.parse_scanner(scanner)
          results.concat(result)
        else
          scanner.pos = previous_pos
          return nil
        end
      end

      results
    end

    def & (other)
      self.class.new(*(@expressions + [other]))
    end
  end
  
  class Expression
    def & (other)
      if other.is_a?(Sequence)
        Sequence.new(self, *other.expressions)
      else
        Sequence.new(self, other)
      end
    end
  end
end