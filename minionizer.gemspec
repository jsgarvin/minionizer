require_relative 'lib/minionizer/version'

Gem::Specification.new do |s|
  s.name = "minionizer"
  s.version = Minionizer::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Jonathan S. Garvin"]
  s.email = ["jon@5valleys.com"]
  s.homepage = "https://github.com/jsgarvin/minionizer"
  s.summary = %q{Simple server provisioning and management.}
  s.description = %q{Minionizer aims to be a light weight server provisioning tool without bloat or steep learning curves.}

  s.add_dependency('activesupport')

  s.add_development_dependency('mocha')

  s.add_development_dependency('fakefs')

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- test/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
