# DSV/Error.rb
# DSV::Error

class DSV
  # The base of what dsv raises about the data, so that one rescue catches all of it.
  class Error < ::StandardError
  end
end
