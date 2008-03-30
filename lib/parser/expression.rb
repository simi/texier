class Texier::Parser
  # Base class for parsing expressions.
  class Expression
    def peek(scanner)
      previous_pos = scanner.pos
      result = parse(scanner)
      scanner.pos = previous_pos

      result
    end

    # Ordered choice
    def | (other)
      if other.is_a?(Choice)
        Choice.new(self, *other.expressions)
      else
        Choice.new(self, other)
      end
    end

    # Sequence
    def & (other)
      if other.is_a?(Sequence)
        Sequence.new(self, *other.expressions)
      else
        Sequence.new(self, other)
      end
    end
        
    # Positive lookahead
    def +@
      PositiveLookahead.new(self)
    end
        
    # Negative lookahead
    def -@
      NegativeLookahead.new(self)
    end

    # TODO: describe this
    def map(&block)
      Mapper.new(self, &block)
    end

    # TODO: describe this
    def group
      map {|*results| [results]}
    end
        
    def create(something)
      self.class.create(something)
    end

    def self.create(something)
      case something
      when ::String then String.new(something)
      when ::Regexp then Regexp.new(something)
      when Expression then something
      else raise Error,
          "I dont know how to create expression from #{something.class.name}"
      end
    end
  end
  
  # Helper method to generate various types of parsing expressions.
  module Generators
    # Create expression from string or regexp literals. If passed argument is
    # already Expression instance, it is returned unchanged.
    def expression(something, &block)
      result = Expression.create(something)
      result = result.map(&block) if block_given?
      result
    end

    alias_method :e, :expression
  end
end