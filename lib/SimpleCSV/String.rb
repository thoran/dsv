# SimpleCSV/String.rb
# SimpleCSV::String

require 'stringio'

require_relative File.join('..', 'SimpleCSV')

class SimpleCSV
  class String < SimpleCSV

    def initialize(string, *args)
      @string = string
      super(source, *args)
    end

    def source
      @source ||= StringIO.new(@string)
    end

  end
end
