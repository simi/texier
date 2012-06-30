# 
# Copyright (c) 2008 Adam Ciganek <adam.ciganek@gmail.com>
# 
# This file is part of Texier.
# 
# Texier is free software: you can redistribute it and/or modify it under the
# terms of the GNU General Public License version 2 as published by the Free
# Software Foundation.
# 
# Texier is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along with
# Texier. If not, see <http://www.gnu.org/licenses/>.
# 
# For more information please visit http://code.google.com/p/texier/
# 

module Texier
  module Modules
    # The features of Texier are separated into self-contained modules. These
    # modules can then be added to/removed from Texier according to what
    # features are needed. It is also very easy to extend Texier's functionality
    # by writing your own module.
    # 
    # This is the base class for all Texier modules.
    class Base
      # The main Texier::Base object.
      attr_accessor :base
    
      def dtd
        base.dtd
      end
    
      # This method is called before parsing. Derived classes should override it
      # if they need to preprocess the input document.
      def before_parse(input)
        input
      end
    
      # This method is called after parsing. Derived classes should override it
      # if they need to do something with dom tree.
      def after_parse(dom)      
      end
    
      def initialize_parser
        exported_expressions.each do |name, block|
          base.expressions[name] = instance_eval(&block)
        end
        
        extending_expressions.each do |(slot, name, block)|
          if base.allowed[name]
            base.expressions[:"#{slot}_slot"] << instance_eval(&block)
          end
        end
      end
      
      protected
      
      # Build DOM element.
      def build(*args)
        Texier::Element.new(*args)
      end
      
      @@extending_expressions = {}
    
      def self.extend_expression(slot, name, export = false, &block)
        @@extending_expressions[self] ||= []
        @@extending_expressions[self] << [slot, name, block]
        
        export_expression(name.to_sym, &block) if export
      end
      
      # Define new inline element.
      def self.inline_element(name, export = false, &block)
        extend_expression(:inline_element, name, export, &block)
      end
    
      # Define new block element.
      def self.block_element(name, export = false, &block)
        extend_expression(:block_element, name, export, &block)
      end
    
      def extending_expressions
        @@extending_expressions[self.class] || []
      end

      @@exported_expressions = {}
      
      # Export expression so it can be used by other modules.
      def self.export_expression(name, &block)
        @@exported_expressions[self] ||= {}
        @@exported_expressions[self][name] = block
      end
      
      def exported_expressions
        @@exported_expressions[self.class] || {}
      end
      
      # Helper methods for generating parser rules.
      include Parser::Generators
    
      # Access exported parser expressions as ordinary methods.
      def method_missing(name, *args, &block)
        if expression = base.expressions[name]
          expression
        else
          super
        end
      end


      
      # Define module options. Options are defined as hash, where key is the
      # name of the option and value is it's default value.
      def self.options(hash)
        hash.each do |name, default_value|
          attr_writer name
          define_method(name) do
            if instance_variable_defined?("@#{name}")
              instance_variable_get("@#{name}")
            else
              default_value
            end
          end
        
          # Create method with question mark at the end.
          alias_method "#{name}?", name if [true, false].include?(default_value)
        end
      end
    end
  end
end