require 'strscan'

require "#{File.dirname(__FILE__)}/element"
require "#{File.dirname(__FILE__)}/error"

module Texier
  # Parser based on theory of Parsing Expression Grammars (PEG)
  class Parser
    def initialize
      @rules = {}
    end
    
    # Access to exported expressions.
    def [](name)
      # TODO: raise exception if expression not defined.
      @rules[name]
    end
    
    # Add expression to exported expressions
    def []=(name, value)
      @rules[name] = value
    end
    
    def has_expression?(name)
      @rules.has_key?(name)
    end
    
    # Parse the string.
    def parse(input)
      raise Error unless @rules[:document]
      
      scanner = StringScanner.new(input)      
      @rules[:document].parse(scanner)
    end
    
    # Helper method to generate various types of parsing expressions.
    module Generators
      # Create expression from string or regexp literals. If passed argument is
      # already Expression instance, it is returned unchanged.
      def expression(something, &block)
        result = Expressions::Expression.create(something)
        result = result.map(&block) if block_given?
        result
      end
      
      # Create empty expression that never matches anything.
      # It is actualy Choice, so other expression can be added to it later
      # using << operator.
      def empty
        Expressions::Choice.new
      end
      
      # Creates expression that matches everything from current position up to
      # position where another expression matches.
      def everything_up_to(expression)
        Expressions::EverythingUpTo.new(expression)
      end

      # Creates expression that matches zero or more occurences of another
      # expression.
      def zero_or_more(rule)
        Expressions::Repetition.new(rule, 0)
      end
    
      
      def one_or_more(rule)
        Expressions::Repetition.new(rule, 1)
      end
      
    end
    
    # Expression classes.
    module Expressions
      class Expression
        def parse(scanner)
        end
      
        def peek(scanner)
          previous_pos = scanner.pos
          result = parse(scanner)
          scanner.pos = previous_pos
        
          result
        end
        
        # Ordered choice
        def | (other)
          Choice.new(self, other)
        end
        
        # Sequence
        def & (other)
          Sequence.new(self, other)
        end
        
        def map(&block)
          Mapper.new(self, &block)
        end
        
        def create(something)
          self.class.create(something)
        end
        
        def self.create(something)
          case something
          when ::String then Expressions::String.new(something)
          when ::Regexp then Expressions::Regexp.new(something)
          when Expressions::Expression then something
          else raise Error, 
              "I dont know how to create expression from #{something.class.name}"
          end
        end
      end
      
      class Mapper < Expression
        def initialize(expression, &block)
          @expression = create(expression)
          @block = block
        end
      
        def parse(scanner)
          if result = @expression.parse(scanner)
            @block.call(*result)
          end
        end
      end      
    
      # Expression that matches a string.
      class String < Expression
        def initialize(string = '')
          @string = string
        end
      
        def parse(scanner)
          if scanner.peek(@string.length) == @string
            scanner.pos += @string.length
            @string
          else
            nil
          end
        end
      end

      # Expression that matches when regexp matches.
      class Regexp < Expression
        def initialize(regexp = //)
          @regexp = regexp
        end
      
        def parse(scanner)
          scanner.scan(@regexp)
        end
      end
      
      # Ordered choice.
      class Choice < Expression
        def initialize(*expressions)
          @expressions = expressions.map do |expression|
            create(expression)
          end
        end
      
        def parse(scanner)
          @expressions.each do |expression|
            if result = expression.parse(scanner)
              return result
            end
          end
          
          nil
        end
        
        def << (other)
          @expressions << other
        end
      end
      
      # TODO: describe what is this good for.
      class ChoiceWithDefault < Choice
        def << (other)
          if @expressions.empty?
            @expressions << other
          else
            last = @expressions.pop
            @expressions << other << last          
          end
        end
      end

      # Sequence of expressions
      class Sequence < Expression
        def initialize(*expressions)
          @expressions = expressions.map do |expression|
            create(expression)
          end
        end
      
        def parse(scanner)
          previous_pos = scanner.pos
          results = []
        
          @expressions.each do |expression|
            if result = expression.parse(scanner)
              results << result
            else
              scanner.pos = previous_pos
              return nil
            end
          end
          
          results
        end
        
        def & (other)
          self.class.new(*(@expressions + [other]))
        end
      end

      class Repetition < Expression
        def initialize(expression, min)
          @expression = create(expression)
          @min = min
        end
      
        def parse(scanner)
          previous_pos = scanner.pos
          results = []
        
          while result = @expression.parse(scanner)
            results << result
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
      end

      class RepetitionWithSeparator < Expression
        def initialize(rule, separator, min)
          @expression = self.class.create(rule)
          @separator = self.class.create(separator)
          @min = min
        end
      
        def parse(scanner)
          # Ok, so what is this about?
          # 
          # Let's say that i want to parse strings like this:
          # 
          #   "foo,foo,foo,foo,foo"
        
          # First, i save current position of scanner, because if parsing fails,
          # i have to reset it to where it was before.
          previous_pos = scanner.pos
          results = []
        
          # Here is try to parse first occurence of "foo". I do this in separate
          # step, because there is no separator at the beggining. If it
          # succeeds, i save the result to results array, if not, i just
          # continue anyway.
          result = @expression.parse(scanner)
          results << result if result
        
          # Now in this loop i try to parse pairs [",", "foo"] until there are
          # no more left. It can happen that the separator is matched, but "foo"
          # is not. In that case i need to reset scanner's position to just
          # before last separator, because this separator is actualy not part of
          # list that i want to parse.
          while true
            pos_before_separator = scanner.pos          
            break unless @separator.parse(scanner)
                    
            if result = @expression.parse(scanner)
              # If it matches, store only the "foo" and ignore separator.
              results << result
            else
              # If not, return position before last separator and end the loop.
              scanner.pos = pos_before_separator
              break
            end
          end
        
          # Here i check if enought occurences of "foo" was parsed. If yes, the
          # parsing is succesfull, if not, it fails.
          if results.size >= @min
            results
          else
            scanner.pos = previous_pos
            nil
          end        
        end
      end

      # This expression matches everything from current position up to position
      # where another expression matches.
      class EverythingUpTo < Expression
        def initialize(expression)
          @expression = create(expression)
        end
      
        def parse(scanner)
          result = nil
        
          until @expression.peek(scanner)
            return nil unless char = scanner.getch
          
            result ||= ''
            result << char
          end
        
          result
        end
      end
      
    end
  end
end