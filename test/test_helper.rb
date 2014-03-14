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
      FileUtils.mkdir_p missions_path
      File.open("#{missions_path}/#{name}.rb", 'w') { |mission| mission.write '' }
    end

    def missions_path
      @missions_path ||= File.expand_path('./missions')
    end

  end
end

require 'mocha/setup'
