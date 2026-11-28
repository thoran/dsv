# DSV/UnexpectedRow.rb
# DSV::UnexpectedRow

# frozen_string_literal: true

class DSV
  # A row which contradicts its declared quote mode; mode is the mode in force, and line the one on which the row began, given by the reader once it knows it.
  class UnexpectedRow < Error
    attr_reader :mode
    attr_accessor :line

    def initialize(mode, line = nil)
      @mode = mode
      @line = line
      super()
    end

    def message
      "The row beginning on line #{@line} does not keep to quote: #{@mode.inspect}."
    end
  end
end
