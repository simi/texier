module Texier
  # The features of Texier processor are separated into self-contained modules.
  # These modules can then be added to/removed from Texier processor according
  # to what features are needed. It is also very easy to extend Texier's
  # functionality by writing your own module.
  # 
  # This is the base class for all Texier modules.
  class Module
    def initialize(processor)
      @processor = processor
    end
    
    # Preprocess the input string before parsing starts. This method should be
    # overriden in derived classes if preprocessing is needed.
    def preprocess(input)
      input
    end
    
    # Add rules to parser.
    def initialize_parser(parser)
      
    end
    
  end
end
