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

  s.add_dependency('activesupport', '~> 5.2')
  s.add_dependency('binding_of_caller', '~> 0.8')
  s.add_dependency('net-ssh', '~> 5.2')
  s.add_dependency('net-scp', '~> 2.0')

  s.add_development_dependency('fakefs', '~> 0.5')
  s.add_development_dependency('mocha', '~> 1.0')
  s.add_development_dependency('minitest', '~> 5.11')
  s.add_development_dependency('rake', '~> 12.3.3')

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- test/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
