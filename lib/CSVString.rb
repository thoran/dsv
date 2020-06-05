# CSVString.rb

require 'stringio'

require_relative 'SimpleCSV'

class CSVString < SimpleCSV

  class << self

    def open(source, *args, &block)
      @csv_file = CSVString.new(source, *args)
      super(source, *args, &block)
    end

  end # class << self

  def initialize(string, *args)
    @string = string
    super(source, *args)
  end

  def source
    @source ||= StringIO.new(@string)
  end

end
