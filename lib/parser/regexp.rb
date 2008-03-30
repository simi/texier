class Texier::Parser
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
end