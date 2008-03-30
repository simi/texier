module Texier::Parser
  # TODO: describe this
  class Repetition < Expression
    def initialize(expression, min)
      @expression = e(expression)
      @min = min
    end

    def parse_scanner(scanner)
      previous_pos = scanner.pos
      results = []

      while result = @expression.parse_scanner(scanner)
        results.concat(result)
      end

      if results.size >= @min
        results
      else
        scanner.pos = previous_pos
        nil
      end
    end

    def separated_by(separator)
      RepetitionWithSeparator.new(@expression, separator, @min)
    end

    def up_to(stop)
      RepetitionUpTo.new(@expression, stop, @min)
    end
  end
  
  class Expression
    # Expression that matches zero or more occurences of this expression.
    def zero_or_more
      Repetition.new(self, 0)
    end

    def one_or_more
      Repetition.new(self, 1)
    end
  end
end