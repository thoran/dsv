# DSV/Error.rb
# DSV::Error

# frozen_string_literal: true

class DSV
  # The base of what dsv raises about the data, so that one rescue catches all of it.
  class Error < ::StandardError
  end
end
