require 'rake/testtask'
require 'pty'

require_relative 'lib/minionizer'

task default: :test

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

#Rake::TestTask.new(:start_test_vm) do |t|
namespace :test do
  namespace :vm do
    task :start do
      relay_output(vagrant_command(:up))
    end
    task :stop do
      relay_output(vagrant_command(:halt))
    end
  end
end

def vagrant_command(command)
  "cd #{File.expand_path('../test', __FILE__)}; vagrant #{command}"
end

def relay_output(command)
  begin
    PTY.spawn(command) do |stdin, stdout, pid|
      begin
        stdin.each {|line| print line }
      rescue Errno::EIO
      end
    end
  rescue PTY::ChildExited
  end
end
