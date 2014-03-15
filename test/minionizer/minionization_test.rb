require 'test_helper'

module Minionizer
  class MinionizationTest < MiniTest::Unit::TestCase

    describe Minionization do
      let(:minion_name) { 'foo.bar.com' }
      let(:config) { Configuration.instance }
      let(:role_name) { 'web_server' }
      let(:role_class) { get_anonymous_class(role_name) }
      let(:minionization) { Minionization.new(arguments, config) }
      let(:minions) {{ minion_name => { 'roles' => [role_name] }}}

      before do
        write_role_file(role_name)
        config.stubs(:minions).returns(minions)
      end

      describe 'calling with a valid minion name' do
        let(:arguments) { [minion_name] }

        it 'executes a role' do
          minionization.expects(:require).with("/roles/#{role_name}.rb")
          role_class.any_instance.expects(:call).with(minionization)
          minionization.call
        end
      end

      describe 'calling with a valid role' do
        let(:arguments) { [role_name] }

        it 'executes the role once for each minion' do
          minionization.expects(:require).with("/roles/#{role_name}.rb")
          role_class.any_instance.expects(:call).with(minionization)
          minionization.call
        end
      end
    end

  end
end
