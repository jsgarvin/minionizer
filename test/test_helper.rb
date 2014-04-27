require 'rubygems'
require 'minitest/autorun'
require 'fakefs/safe'
require 'socket'
require 'timeout'

require_relative '../lib/minionizer'

module Minionizer
  class MiniTest::Unit::TestCase

    def before_setup
      super
      initialize_fakefs
    end

    def after_teardown
      super
      FakeFS.deactivate!
    end

    #######
    private
    #######

    def initialize_fakefs
      FakeFS.activate!
      FakeFS::FileSystem.clear
      Kernel.class_eval do
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
      Timeout.timeout(1) do
        @minion_available ||= TCPSocket.new('192.168.49.181', 22)
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
  end
end

module Kernel

  def fake_require(path)
    File.open(path, "r") {|f| Object.class_eval f.read, path, 1 }
  end

end

require 'mocha/setup'
