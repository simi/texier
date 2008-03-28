require 'strscan'

require "#{File.dirname(__FILE__)}/element"
require "#{File.dirname(__FILE__)}/error"

module Texier
  # Parser generator based on the theory of Parsing Expression Grammars (PEG).
  #
  # TODO: describe it in more detail.
  # 
  # OPTIMIZE: using packrat parsing.
  class Parser
    def initialize
      @expressions = {}
    end

    # Access to exported expressions.
    def [](name)
      raise Error, "Expression \"#{name}\" not defined." unless @expressions.has_key?(name)
      @expressions[name]
    end

    # Add expression to exported expressions
    def []=(name, value)
      @expressions[name] = value
    end

    def has_expression?(name)
      @expressions.has_key?(name)
    end

    # Parse the string.
    def parse(input)
      raise Error, 'Starting expression not defined.' unless @expressions[:document]

      scanner = StringScanner.new(input)
      @expressions[:document].parse(scanner)
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

      alias_method :e, :expression

      # Create empty expression that never matches anything. It is actualy
      # Choice, so other expression can be added to it later using << operator.
      def empty
        Expressions::Choice.new
      end

      # Creates expression that matches everything from current position up to
      # position where another expression matches plus the result of that
      # another expression.
      def everything_up_to(e)
        Expressions::EverythingUpTo.new(e)
      end

      # Expression that matches text inside quotes.
      def quoted_text(opening, closing = opening)
        discard(opening) & everything_up_to(discard(closing))
      end

      # Creates expression that matches zero or more occurences of another
      # expression.
      def zero_or_more(e)
        Expressions::Repetition.new(e, 0)
      end


      def one_or_more(e)
        Expressions::Repetition.new(e, 1)
      end

      def optional(e)
        Expressions::Optional.new(e)
      end

      # Match expression, but discard the result.
      def discard(e)
        expression(e).map {[]}
      end

      # Match expression only in indented string. TODO: describe this in more
      # detail.
      def indented(e, indent_re = /^[ \t]+/)
        Expressions::Indented.new(e, indent_re)
      end
    end

    # Expression classes.
    module Expressions
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
          when ::String then Expressions::String.new(something)
          when ::Regexp then Expressions::Regexp.new(something)
          when Expressions::Expression then something
          else raise Error,
              "I dont know how to create expression from #{something.class.name}"
          end
        end
      end

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

      # Expression that matches a string.
      class String < Expression
        def initialize(string = '')
          @string = string
        end

        def parse(scanner)
          if scanner.peek(@string.length) == @string
            scanner.pos += @string.length
            [@string]
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
          result = scanner.scan(@regexp)
          result ? [result] : nil
        end
      end

      # Ordered choice.
      class Choice < Expression
        attr_reader :expressions

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

        def << (expression)
          @expressions << expression
        end
      end

      # Sequence of expressions
      class Sequence < Expression
        attr_reader :expressions

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
              results.concat(result)
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

      # Expression is optional.
      class Optional < Expression
        def initialize(expression)
          @expression = create(expression)
        end

        def parse(scanner)
          @expression.parse(scanner) || [nil]
        end
      end

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

      # TODO: describe this
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
          results.concat(result) if result

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
              results.concat(result)
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

      # TODO: describe this
      class Indented < Expression
        def initialize(expression, indent_re)
          @expression = create(expression)
          @indent_re = indent_re
        end

        def parse(scanner)
          indented_part = ''
          indent_lengths = []

          indent_re = @indent_re

          # Remove indentation from the beggining of each line.
          scanner.rest.each_line do |line|
            if line =~ /^[ \t]*$/
              indent = ''
            else
              break unless indent = line.slice!(indent_re)
              indent_re = /^#{::Regexp.quote(indent)}/
            end

            indented_part << line
            indent_lengths << indent.to_s.length
          end

          indented_scanner = StringScanner.new(indented_part)
          result = @expression.parse(indented_scanner)

          lines = indented_part[0..indented_scanner.pos].count("\n")
          
          # Compute position offset from begining of indented part to the
          # position where parsing ended.
          scanner.pos += indented_scanner.pos +
            indent_lengths[0..lines].inject(0) {|o, l| o + l}
          
          result
        end
      end
    end
  end
end
