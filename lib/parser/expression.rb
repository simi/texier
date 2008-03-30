module Texier::Parser
  # Helper method to generate various types of parsing expressions.
  module Generators
    # Create expression from string or regexp literals. If passed argument is
    # already Expression, it is returned unchanged.
    def expression(something, &block)
      result = case something
      when ::String then String.new(something)
      when ::Regexp then Regexp.new(something)
      when Expression then something
      else raise Error, "I dont know how to create expression from #{something.class.name}"
      end
      
      result = result.map(&block) if block_given?
      result
    end

    alias_method :e, :expression
  end
  
  # Base class for parsing expressions.
  class Expression
    include Generators
    
    def parse_string(string)
      parse_scanner(StringScanner.new(string))
    end
    
    alias_method :parse, :parse_string
    
    def peek(scanner)
      previous_pos = scanner.pos
      result = parse_scanner(scanner)
      scanner.pos = previous_pos

      result
    end
  
    # TODO: describe this
    def group
      map {|*results| [results]}
    end

    # Match expression, but discard the result.
    def skip
      map {[]}
    end
  end
end