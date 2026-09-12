# test/gemspec_test.rb

require_relative './helper'

# Two gemspecs, two registrations of the one library: each names the gem after
# its own file, and both are built by gem-publish, which builds every *.gemspec
# in the directory.  Both are checked here, the second having gone unchecked
# while this file named the first outright.
['dsv.gemspec', 'dsv.rb.gemspec'].each do |filename|
  describe filename do
    let(:spec){Gem::Specification.load(File.expand_path("../#{filename}", __dir__))}

    it "is a valid specification" do
      _(spec.validate).must_equal(true)
    end

    it "does not pin a date" do
      _(spec.date).must_equal(Gem::Specification.new.date)
    end

    it "takes its version from DSV::VERSION" do
      _(spec.version.to_s).must_equal(DSV::VERSION)
    end

    it "names the gem after its own file" do
      _(spec.name).must_equal(filename.delete_suffix('.gemspec'))
    end

    it "ships its own gemspec and not the other" do
      _(spec.files).must_include(filename)
      _(spec.files.grep(/\.gemspec\z/)).must_equal([filename])
    end

    it "declares no runtime dependencies" do
      _(spec.runtime_dependencies).must_equal([])
    end

    it "declares minitest-mock, which minitest no longer bundles" do
      _(spec.development_dependencies.collect(&:name)).must_include('minitest-mock')
    end
  end
end
