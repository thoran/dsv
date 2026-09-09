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
      @mode ||= DSV.normalised_mode(options[:mode])
    end

    # The trailing Hash of the arguments, left in place for the parent to take.
    def options
      @args.last.is_a?(::Hash) ? @args.last : {}
    end

    def permissions
      @permissions ||= options[:permissions]
    end

    attr_reader :filename

  end
end
