# DSV/UnterminatedQuote.rb
# DSV::UnterminatedQuote

class DSV
  # A quoted field which does not close by the end of the source; line is the one on which its row began.
  class UnterminatedQuote < ::StandardError
    attr_reader :line

    def initialize(line)
      @line = line
      super("A quoted field in the row beginning on line #{line} does not close.")
    end
  end
end
