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

    def minion_available?
      Timeout.timeout(1) do
        @@minion_available ||= TCPSocket.new('192.168.49.181', 22)
      end
    rescue Errno::ECONNREFUSED, Timeout::Error
      return false
    end

    def initialize_minion
      @@previously_initialized ||= `cd #{File.dirname(__FILE__)}; vagrant up`
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

  end
end

module Kernel

  def fake_require(path)
    File.open(path, "r") {|f| Object.class_eval f.read, path, 1 }
  end

end

module MiniTest
  class NamedMock < Mock
    attr_reader :name

    def initialize(name)
      @name = name
      super()
    end

    # Because you ought to be able to
    # test two effing mocks for equality.
    def ==(x)
      object_id == x.object_id
    end

    def method_missing(sym, *args, &block)
      super(sym, *args, &block)
    rescue NoMethodError, MockExpectationError, ArgumentError => error
      raise(error.class, "#{error.message} (mock:#{name}) ")
    end
  end
end

require 'mocha/setup'
