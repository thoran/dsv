# dsv.gemspec

require_relative './lib/DSV/VERSION'

class Gem::Specification
  def development_dependencies=(gems)
    gems.each{|gem| add_development_dependency(*gem)}
  end
end

Gem::Specification.new do |spec|
  spec.name = 'dsv'
  spec.version = DSV::VERSION

  spec.summary = "Read and write delimiter-separated values."
  spec.description = "Read and write the DSV family of files (CSV, TSV, etc.) from disk or in memory."

  spec.author = 'thoran'
  spec.email = 'code@thoran.com'
  spec.homepage = "https://github.com/thoran/dsv"
  spec.license = 'MIT'

  spec.required_ruby_version = '>= 3.2'
  spec.require_paths = ['lib']

  spec.files = [
    'dsv.gemspec',
    Dir['lib/**/*.rb'],
    Dir['test/**/*.rb'],
    'CHANGELOG',
    'Gemfile',
    'LICENSE',
    'Rakefile',
    'README.md',
    'TODO',
  ].flatten

  spec.development_dependencies = [
    ['minitest', '~> 6.0'],
    'minitest-mock',
    'rake',
  ]
end
