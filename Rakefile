require 'rake/testtask'
require_relative 'lib/minionizer'

task default: :test

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

Rake::TestTask.new(:start_test_vm) do |t|
  `cd #{File.expand_path('../test', __FILE__)}; vagrant up`
end
