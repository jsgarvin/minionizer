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

namespace :test do
  namespace :vm do
    task :start do
      relay_output(vagrant_command(:up))
      unless snapshot_plugin_installed?
        relay_output(vagrant_command('plugin install vagrant-vbox-snapshot'))
        relay_output(vagrant_command('snapshot take blank-test-slate'))
      end
    end
    task :stop do
      relay_output(vagrant_command(:halt))
    end
  end
end

def vagrant_command(command)
  "cd #{vagrant_path}; vagrant #{command}"
end

def snapshot_plugin_installed?
  vagrant_plugins['vagrant-vbox-snapshot'] &&
    Gem::Version.new(vagrant_plugins['vagrant-vbox-snapshot']) >= Gem::Version.new('0.0.4')
end

def vagrant_plugins
  Hash.new.tap do |hash|
    `cd #{vagrant_path}; vagrant plugin list`.split("\n").each do |plugin_string|
      if plugin_string.match(/([^\s]+)\s\(([0-9\.]+)/)
        hash[$1] = $2
      end
    end
  end
end

def vagrant_path
  File.expand_path('../test', __FILE__)
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
