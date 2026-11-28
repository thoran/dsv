# DSV/UnterminatedQuote.rb
# DSV::UnterminatedQuote

# frozen_string_literal: true

class DSV
  class UnterminatedQuote < Error
    attr_reader :line

    def initialize(line)
      @line = line
      super("A quoted field in the row beginning on line #{line} does not close.")
    end
  end
end
