class Texier::Parser
  # TODO: describe this.
  class EverythingUpTo < Expression
    def initialize(up_to)
      @up_to = create(up_to)
    end

    def parse(scanner)
      result = ''

      until up_to = @up_to.parse(scanner)
        return nil unless char = scanner.getch
        result << char
      end

      result.empty? ? nil : [result] + up_to
    end
  end

  module Generators
    # Creates expression that matches everything from current position up to
    # position where another expression matches plus the result of that another
    # expression.
    def everything_up_to(e)
      EverythingUpTo.new(e)
    end
  end
end