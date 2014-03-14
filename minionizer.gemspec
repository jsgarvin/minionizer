require_relative 'lib/minionizer/version'

Gem::Specification.new do |s|
  s.name = "minionizer"
  s.version = Minionizer::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Jonathan S. Garvin"]
  s.email = ["jon@5valleys.com"]
  s.homepage = "https://github.com/jsgarvin/minionizer"
  s.summary = %q{Simple infrastructure setup and management.}
  s.description = %q{Minionizer allows you to manage software installations and configurations on one or more machines without a lot of bloat or a steep learning curve.}

  s.add_dependency('activesupport')

  s.add_development_dependency('mocha')

  s.add_development_dependency('fakefs')

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- test/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
