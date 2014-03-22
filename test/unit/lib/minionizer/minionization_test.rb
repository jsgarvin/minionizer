require 'test_helper'

module Minionizer
  class MinionizationTest < MiniTest::Unit::TestCase

    describe Minionization do
      let(:fqdn) { 'foo.bar.com' }
      let(:config) { Configuration.instance }
      let(:role_name) { 'web_server' }
      let(:role_class) { get_dynamic_class(role_name) }
      let(:minion) { MiniTest::NamedMock.new('minion') }
      let(:minionization) { Minionization.new(arguments, config, minion_constructor) }
      let(:minion_roles) {{ fqdn => { 'roles' => [role_name] }}}
      let(:minion_constructor) { Struct.new(:fqdn, :config) }
      let(:session) { MiniTest::NamedMock.new('session') }
      let(:role) { MiniTest::NamedMock.new('role') }

      before do
        config.stubs(:minions).returns(minion_roles)
        minion.expect(:roles, [role_name])
        minion_constructor.expects(:new).with(fqdn, config).returns(minion)
        role_class.expects(:new).with(session).returns(role)
        role.expect(:call, true)
        minionization.expects(:require).with("/roles/#{role_name}.rb")
        minion.expect(:session, session)
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
