require 'test_helper'

module Minionizer
  class MinionizationTest < MiniTest::Unit::TestCase

    describe Minionization do

      let(:mock_config) { MiniTest::Mock.new }
      let(:role_name) { 'vpn_server' }
      let(:minion_name) { 'foo.bar.com' }
      let(:arguments) { [minion_name] }
      let(:minionization) { Minionization.new(arguments, mock_config) }

      before do
        write_role_file(role_name)
      end

      describe 'calling with a valid role name' do
        let(:minions) {{ minion_name => { 'roles' => [role_name] }}}

        before do
          mock_config.expect(:minions, minions)
        end

        after do
          mock_config.verify
        end

        it 'executes a role' do
          minionization.expects(:require).with("/roles/#{role_name}.rb")
          minionization.call
        end
      end
    end

  end
end
