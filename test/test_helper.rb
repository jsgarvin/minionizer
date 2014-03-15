require 'rubygems'
require 'minitest/autorun'
require 'fakefs/safe'

require 'minionizer'

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
    end

    def write_role_file(name)
      write_file("roles/#{name}.rb")
    end

    def write_file(path, contents = '')
      FileUtils.mkdir_p File.dirname(path)
      File.open("./#{path}", 'w') { |file| file.write(contents) }
    end

    def get_anonymous_class(name)
      Object.const_get(name.classify)
    rescue NameError
      Object.const_set(name.classify, Class.new)
    end

  end
end

require 'mocha/setup'
