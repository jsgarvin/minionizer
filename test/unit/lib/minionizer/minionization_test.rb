require 'test_helper'

module Minionizer
  class MinionizationTest < MiniTest::Unit::TestCase

    describe Minionization do
      let(:fqdn) { 'foo.bar.com' }
      let(:config) { Configuration.instance }
      let(:role_name) { 'web_server' }
      let(:role_class) { get_dynamic_class(role_name) }
      let(:minion) { quacks_like_instance_of(Minion) }
      let(:minionization) { Minionization.new(arguments, config, minion_constructor) }
      let(:minion_roles) {{ fqdn => { 'roles' => [role_name] }}}
      let(:minion_constructor) { quacks_like(Minion) }
      let(:session) { quacks_like_instance_of(Session) }
      let(:role) { quacks_like_instance_of(RoleTemplate) }

      before do
        config.stubs(:minions).returns(minion_roles)
        minion.expects(:roles).returns([role_name])
        minion.expects(:session).returns(session)
        minion_constructor.expects(:new).with(fqdn, config).returns(minion)
        role_class.expects(:new).with(session).returns(role)
        role.expects(:call)
        minionization.expects(:require).with("/roles/#{role_name}.rb")
      end

      describe 'calling with a valid minion name' do
        let(:arguments) { [fqdn] }

        it 'executes a role' do
          minionization.call
        end
      end

      describe 'calling with a valid role' do
        let(:arguments) { [role_name] }

        it 'executes the role once for each minion' do
          minionization.call
        end
      end
    end

  end
end
