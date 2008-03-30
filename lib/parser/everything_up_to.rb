module Texier::Parser
  # TODO: describe this.
  class EverythingUpTo < Expression
    def initialize(up_to)
      @up_to = e(up_to)
    end

    def parse_scanner(scanner)
      result = ''

      until up_to = @up_to.parse_scanner(scanner)
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
    
    # Expression that matches text inside quotes.
    def quoted_text(opening, closing = opening)
      e(opening).skip & everything_up_to(e(closing).skip)
    end
  end
end