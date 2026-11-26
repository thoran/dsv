# DSV/File.rb
# DSV::File

require_relative '../dsv'

class DSV
  class File < DSV
    class << self
      def source(filename, options = {})
        ::File.new(::File.expand_path(filename), DSV.normalised_mode(options[:mode]), options[:permissions])
      end
    end # class << self

    def source
      @source ||= DSV::File.source(filename, options)
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

    private

    def initialize(filename, *args)
      @filename = ::File.expand_path(filename)
      @args = args
      super(source, *args)
    end
  end
end
