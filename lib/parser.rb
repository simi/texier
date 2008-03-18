require 'strscan'

require "#{File.dirname(__FILE__)}/element"
require "#{File.dirname(__FILE__)}/error"

module Texier
  # 
  class Parser
    # Starting rule of parser's grammar.
    attr_accessor :start
    
    def initialize(&block)
      @rules = Hash.new do |hash, key|
        hash[key] = Choice.new
      end
      
      define(&block) if block_given?
    end

    # Define rules of parser's grammar.
    def define(&block)
      instance_eval(&block)
    end
    
    
    # Parse the string.
    def parse(input)
      scanner = StringScanner.new(input)      
      @rules[start].parse(scanner)
    end
    
    # Is that rule defined?
    def has_rule?(name)
      @rules.has_key?(name)
    end

    # Base class for parsing rules.
    class Rule
      def parse(scanner)
      end
      
      def peek(scanner)
        previous_pos = scanner.pos
        result = parse(scanner)
        scanner.pos = previous_pos
        
        result
      end

      # If the argument is String, Regexp or Array, this method will wrap it
      #   with corresponding Rule subclass. If it is already Rule, it will
      #   return it unchanged.
      def self.create(*args)
        if args.size > 1
          Sequence.new(*args)
        else
          case args[0]
          when String then StringRule.new(args[0])
          when Regexp then RegexpRule.new(args[0])
          when Rule then args[0]
          else raise Error, 
              "I dont know how to create rule from #{args[0].class.name}"
          end
        end
      end
    end

    
    
    # Rule that matches a string.
    class StringRule < Rule
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
    
    
    
    # Rule that matches when regular expression matches.
    class RegexpRule < Rule
      def initialize(regexp = //)
        @regexp = regexp
      end
      
      def parse(scanner)
        scanner.scan(@regexp)
      end
    end
    
    
    
    # Sequence of rules
    class Sequence < Rule
      def initialize(*rules)
        @rules = rules.map do |rule|
          self.class.create(rule)
        end
      end
      
      def parse(scanner)
        previous_pos = scanner.pos
        results = []
        
        @rules.each do |rule|
          if result = rule.parse(scanner)
            results << result
          else
            scanner.pos = previous_pos
            return nil
          end
        end
          
        results
      end
    end
    
    
    # Ordered choice.
    class Choice < Rule
      def initialize
        @rules = []
      end
      
      # Add another choice to this rule.
      # 
      # TODO: Explain why this is called "is".
      def is(*args, &block)
        rule = self.class.create(*args)
        rule = Mapper.new(rule, &block) if block_given?
        
        @rules << rule
      end
      
      def parse(scanner)
        result = nil
        @rules.each do |choice|
          result = choice.parse(scanner)          
          break if result
        end
        
        result
      end
    end

    
    
    class Mapper < Rule
      def initialize(rule, &block)
        @rule = self.class.create(rule)
        @block = block
      end
      
      def parse(scanner)
        if result = @rule.parse(scanner)
          @block.call(*result)
        end
      end
    end
    
    

    class Repetition < Rule
      def initialize(rule, min)
        @rule = self.class.create(rule)
        @min = min
      end
      
      def parse(scanner)
        previous_pos = scanner.pos
        results = []
        
        while result = @rule.parse(scanner)
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
        RepetitionWithSeparator.new(@rule, separator, @min)
      end
    end

    def zero_or_more(rule)
      Repetition.new(rule, 0)
    end
    
    def one_or_more(rule)
      Repetition.new(rule, 1)
    end


    
    class RepetitionWithSeparator < Rule
      def initialize(rule, separator, min)
        @rule = self.class.create(rule)
        @separator = self.class.create(separator)
        @min = min
      end
      
      def parse(scanner)
        # Ok, so what is this about?
        # 
        # Let's say that i want to parse strings like this:
        # 
        #   "foo,foo,foo,foo,foo"
        
        # First, i save current position of scanner, because if parsing fails, i
        # have to reset it to where it was before.
        previous_pos = scanner.pos
        results = []
        
        # Here is try to parse first occurence of "foo". I do this in separate
        # step, because there is no separator at the beggining. If it succeeds,
        # i save the result to results array, if not, i just continue anyway.
        result = @rule.parse(scanner)
        results << result if result
        
        # Now in this loop i try to parse pairs [",", "foo"] until there are no
        # more left. It can happen that the separator is matched, but "foo" is
        # not. In that case i need to reset scanner's position to just before
        # last separator, because this separator is actualy not part of list
        # that i want to parse (suppose there is string like this: "foo,foo,bar"
        # and i want only the part "foo,foo").
        while true
          pos_before_separator = scanner.pos          
          break unless @separator.parse(scanner)
                    
          if result = @rule.parse(scanner)
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
    
    
    
    # This rule matches everything from current position up to given pattern.
    class EverythingUpTo < Rule
      def initialize(rule)
        @rule = self.class.create(rule)
      end
      
      def parse(scanner)
        result = nil
        
        until @rule.peek(scanner)
          return nil unless char = scanner.getch
          
          result ||= ''
          result << char
        end
        
        result
      end
    end
    
    def everything_up_to(rule)
      EverythingUpTo.new(rule)
    end
    
    private
    
    # This is used to dynamicaly define parser rules:
    def method_missing(name, *args)
      @rules[name]
    end
  end
end
