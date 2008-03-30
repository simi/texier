class Texier::Parser
  # TODO: describe this
  class Mapper < Expression
    def initialize(expression, &block)
      @expression = create(expression)
      @block = block
    end

    def parse(scanner)
      if result = @expression.parse(scanner)
        result = @block.call(*result)
        result.is_a?(Array) ? result : [result]
      end
    end
  end
end