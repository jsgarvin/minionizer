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

    def write_mission(name)
      write_file("missions/#{name}.rb")
    end

    def write_file(path, contents = '')
      FileUtils.mkdir_p File.dirname(path)
      File.open("./#{path}", 'w') { |file| file.write(contents) }
    end

  end
end

require 'mocha/setup'
