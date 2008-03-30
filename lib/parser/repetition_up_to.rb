class Texier::Parser
  # TODO: describe this
  class RepetitionUpTo < Expression
    def initialize(expression, up_to, min)
      @expression = create(expression)
      @up_to = create(up_to)
      @min = min
    end

    def parse(scanner)
      previous_pos = scanner.pos
      results = []

      until up_to = @up_to.parse(scanner)
        return nil unless result = @expression.parse(scanner)
        results.concat(result)
      end

      if results.size >= @min
        [results] + up_to
      else
        scanner.pos = previous_pos
        nil
      end
    end
  end
end