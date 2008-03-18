require 'strscan'

require "#{File.dirname(__FILE__)}/element"
require "#{File.dirname(__FILE__)}/parser/rule"

module Texier
  # 
  class Parser
    # Starting symbol of parser's grammar.
    attr_accessor :start
    
    def initialize(&block)
      @rules = Hash.new do |hash, key|
        hash[key] = Parser::Rule.new(key)
      end
      
      define(&block) if block_given?
    end

    # Define parser rules
    def define(&block)
      instance_eval(&block)
    end
    
    
    # Parse the string.
    def parse(input)
      scanner = StringScanner.new(input)      
      @rules[start].parse(scanner)
    end
    
    private
    
    # This is used to dynamicaly define parser rules:
    def method_missing(name, *args)
      @rules[name]
    end
  end
end
