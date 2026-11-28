# DSV/UnquotedField.rb
# DSV::UnquotedField

# frozen_string_literal: true

class DSV
  class UnquotedField < UnexpectedRow
    def message
      "A field in the row beginning on line #{@line} is not quoted, as quote: #{@mode.inspect} declares every field to be."
    end
  end
end
