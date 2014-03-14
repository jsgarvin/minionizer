require 'test_helper'

module Minionizer
  class MinionizationTest < MiniTest::Unit::TestCase

    describe 'calling with a valid mission name' do
      let(:mission_name) { 'possible' }
      let(:arguments) { [mission_name] }
      let(:minionization) { Minionization.new(arguments) }

      def test_executing_a_mission
        minionization.expects(:require).with("/missions/#{mission_name}.rb")
        minionization.call
      end
    end

  end
end
