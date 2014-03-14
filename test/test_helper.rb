require 'rubygems'
require 'minitest/autorun'

require 'minionizer'

module Minionizer
  class MiniTest::Unit::TestCase

    def before_setup
      super
      capture_stdout
    end

    def after_teardown
      super
      release_stdout
    end

    #######
    private
    #######

    def capture_stdout
      @stdout = $stdout
      $stdout = StringIO.new
    end

    def release_stdout
      $stdout = @stdout
    end

    # Redirect intentional puts from within tests
    # to the *real* STDOUT for troubleshooting.
    def puts(*args)
      @stdout.puts(*args)
    end

  end
end

require 'mocha/setup'
