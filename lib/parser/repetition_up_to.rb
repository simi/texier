module Texier::Parser
  # TODO: describe this
  class RepetitionUpTo < Expression
    def initialize(expression, up_to, min)
      @expression = e(expression)
      @up_to = e(up_to)
      @min = min
    end

    def parse_scanner(scanner)
      previous_pos = scanner.pos
      results = []

      until up_to = @up_to.parse_scanner(scanner)
        return nil unless result = @expression.parse_scanner(scanner)
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