module Texier::Parser
  # TODO: describe this
  # TODO: rename to Map
  class Mapper < Expression
    def initialize(expression, &block)
      @expression = e(expression)
      @block = block
    end

    def parse_scanner(scanner)
      if result = @expression.parse_scanner(scanner)
        result = @block.call(*result)
        result.is_a?(Array) ? result : [result]
      end
    end
  end
  
  class Expression
    def map(&block)
      Mapper.new(self, &block)
    end
  end
end