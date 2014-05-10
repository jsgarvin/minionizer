require 'rubygems'
require 'simplecov'
require 'coveralls'
require 'minitest/autorun'
require 'fakefs/safe'
require 'socket'
require 'tempfile'
require 'timeout'

if Coveralls.will_run?
  Coveralls.wear!
else
  SimpleCov.start
end

PRE_REQUIRED_LIBS = %w{tempfile}

require_relative '../lib/minionizer'

module Minionizer
  class MiniTest::Test

    def before_setup
      super
      initialize_fakefs
    end

    def after_teardown
      super
      FakeFS.deactivate!
      Kernel.class_eval do
        alias_method :require, :real_require
      end
    end

    #######
    private
    #######

    def initialize_fakefs
      FakeFS.activate!
      Kernel.class_eval do
        def fake_require(path)
          if PRE_REQUIRED_LIBS.include?(path)
            return false #real require returns false if library is already loaded
          else
            File.open(path, "r") {|f| Object.class_eval f.read, path, 1 }
          end
        end
        alias_method :real_require, :require
        alias_method :require, :fake_require
      end
    end

    def without_fakefs
      FakeFS.deactivate!
      yield
    ensure
      FakeFS.activate!
    end

    def minion_available?
      self.class.minion_available?
    end

    def self.minion_available?
      if MinionMonitor.minion_available?
        return true
      else
        Timeout.timeout(1) do
          if Net::SSH.start('192.168.49.181', 'vagrant', password: 'vagrant')
            MinionMonitor.minion_available!
            return true
          else
            return false
          end
        end
      end
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Timeout::Error
      return false
    end

    def initialize_minion
      @@previously_initialized ||= `cd #{File.dirname(__FILE__)}; vagrant up`
    end

    def self.roll_back_to_blank_snapshot
      `cd #{File.dirname(__FILE__)}; vagrant snapshot go blank-test-slate`
    end

    def write_role_file(name)
      write_file("roles/#{name}.rb")
    end

    def write_file(path, contents = '')
      FileUtils.mkdir_p File.dirname(path)
      File.open("./#{path}", 'w') { |file| file.write(contents) }
    end

    def get_dynamic_class(name)
      Object.const_get(name.classify)
    rescue NameError
      Object.const_set(name.classify, Class.new)
    end

    def quacks_like(klass)
      mock("Mock(#{klass.to_s})").tap do |object|
        object.responds_like(klass)
      end
    end

    def quacks_like_instance_of(klass)
      mock("InstanceMock(#{klass.to_s})").tap do |object|
        object.responds_like_instance_of(klass)
      end
    end

    def assert_equal(first, second)
      assert(first === second, "'#{second}' expected to be equal to '#{first}'")
    end

    def sudoized(command)
      %Q{sudo bash -c "#{command}"}
    end
  end
end

require 'mocha/setup'

module MinionMonitor
  def self.minion_available?; !!@minion_available; end
  def self.minion_available!; @minion_available = true; end
end

## Only need this until we have FakeFS > 0.5.2 that includes this commit.
## https://github.com/defunkt/fakefs/commit/06eb002da7fb8119a60fef7d50307bd3358c85f3
module FakeFS
  class Dir
    if RUBY_VERSION >= '2.1'
      module Tmpname # :nodoc:
        module_function

        def tmpdir
          Dir.tmpdir
        end

        def make_tmpname(prefix_suffix, n)
          case prefix_suffix
          when String
            prefix = prefix_suffix
            suffix = ""
          when Array
            prefix = prefix_suffix[0]
            suffix = prefix_suffix[1]
          else
            raise ArgumentError, "unexpected prefix_suffix: #{prefix_suffix.inspect}"
          end
          t = Time.now.strftime("%Y%m%d")
          path = "#{prefix}#{t}-#{$$}-#{rand(0x100000000).to_s(36)}"
          path << "-#{n}" if n
          path << suffix
        end

        def create(basename, *rest)
          if opts = Hash.try_convert(rest[-1])
            opts = opts.dup if rest.pop.equal?(opts)
            max_try = opts.delete(:max_try)
            opts = [opts]
          else
            opts = []
          end
          tmpdir, = *rest
          if $SAFE > 0 and tmpdir.tainted?
            tmpdir = '/tmp'
          else
            tmpdir ||= tmpdir()
          end
          n = nil
          begin
            path = File.join(tmpdir, make_tmpname(basename, n))
            yield(path, n, *opts)
          rescue Errno::EEXIST
            n ||= 0
            n += 1
            retry if !max_try or n < max_try
            raise "cannot generate temporary name using `#{basename}' under `#{tmpdir}'"
          end
          path
        end
      end
    end
  end
end

