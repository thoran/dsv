# DSV/String.rb
# DSV::String

# frozen_string_literal: true

require_relative '../dsv'

class DSV
  class String < DSV
    class << self
      # The options are taken, and unused, so that DSV#initialize calls this as it does DSV::File.source.
      def source(string, options = {})
        StringIO.new(string)
      end
    end # class << self

    def source
      @source ||= DSV::String.source(@string)
    end

    private

    def initialize(string, *args)
      @string = string
      super(source, *args)
    end
  end
end
