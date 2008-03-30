class Texier::Parser
  # TODO: describe this
  class Repetition < Expression
    def initialize(expression, min)
      @expression = create(expression)
      @min = min
    end

    def parse(scanner)
      previous_pos = scanner.pos
      results = []

      while result = @expression.parse(scanner)
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
  
  module Generators
    # Creates expression that matches zero or more occurences of another
    # expression.
    def zero_or_more(e)
      Repetition.new(e, 0)
    end


    def one_or_more(e)
      Repetition.new(e, 1)
    end
  end
end