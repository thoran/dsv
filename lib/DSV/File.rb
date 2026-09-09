# DSV/File.rb
# DSV::File

require_relative '../dsv'

class DSV
  class File < DSV

    def initialize(filename, *args)
      @filename = ::File.expand_path(filename)
      @args = args
      super(source, *args)
    end

    def source
      @source ||= ::File.new(filename, mode, permissions)
    end

    def mode
      @mode ||= DSV.normalised_mode(@args.peek_options[:mode])
    end

    def permissions
      @permissions ||= @args.peek_options[:permissions]
    end

    attr_reader :filename

  end
end
