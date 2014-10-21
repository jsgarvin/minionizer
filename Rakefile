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
    desc 'Start Test VM'
    task :start do
      relay_output(vagrant_command(:up))
      unless snapshot_plugin_installed?
        relay_output(vagrant_command('plugin install vagrant-vbox-snapshot'))
      end
      unless test_snapshot_exists?
        sleep 5
        relay_output(vagrant_command('snapshot take blank-test-slate'))
      end
    end
    desc 'Stop Test VM'
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

def test_snapshot_exists?
  vagrant_snapshots.include?('blank-test-slate')
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

def vagrant_snapshots
  Array.new.tap do |snapshots|
    `cd #{vagrant_path}; vagrant snapshot list`.split("\n").each do |snapshot_string|
       if snapshot_string.match(/Name\: ([^\(]+)/)
         snapshots << $1 
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
