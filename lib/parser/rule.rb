module Texier
  class Parser
    class Rule
      def initialize(name = nil)
        @expressions = []
        @name = name
      end
      
      def is(*args)
        @expressions << create_expression(*args)
      end
      
      private
      
      def create_expression(*args)
	
      end
    end
  end
end
