# SimpleCSV/File.rb
# SimpleCSV::File

require_relative File.join('..', 'SimpleCSV')

class SimpleCSV
  class File < SimpleCSV

    def initialize(filename, *args)
      @filename = ::File.expand_path(filename)
      @args = args
      super(source, *args)
    end

    def source
      @source ||= ::File.new(filename, mode, permissions)
    end

    def mode
      @mode ||= SimpleCSV.normalised_mode(@args.peek_options[:mode])
    end

    def permissions
      @permissions ||= @args.peek_options[:permissions]
    end

    attr_reader :filename

  end
end
