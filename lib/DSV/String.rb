# DSV/String.rb
# DSV::String

require_relative '../dsv'

class DSV
  class String < DSV
    def source
      @source ||= StringIO.new(@string)
    end

    private

    def initialize(string, *args)
      @string = string
      super(source, *args)
    end
  end
end
