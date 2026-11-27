# DSV/UnexpectedRow.rb
# DSV::UnexpectedRow

# frozen_string_literal: true

class DSV
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
