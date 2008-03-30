class Texier::Parser
  # Sequence of expressions
  class Sequence < Expression
    attr_reader :expressions

    def initialize(*expressions)
      @expressions = expressions.map do |expression|
        create(expression)
      end
    end

    def parse(scanner)
      previous_pos = scanner.pos
      results = []

      @expressions.each do |expression|
        if result = expression.parse(scanner)
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
end