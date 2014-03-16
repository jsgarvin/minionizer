require 'test_helper'

module Minionizer
  class MinionTest < MiniTest::Unit::TestCase
    describe Minion do
      let(:username) { 'foo' }
      let(:password) { 'bar' }
      let(:credentials) {{ username: username, password: password }}
      let(:config) { Configuration.instance }
      let(:fqdn) { 'foo.bar.com' }
      let(:session_constructor) { Struct.new(:fqdn, :credentials) }
      let(:minion) { Minion.new(fqdn, config, session_constructor) }

      it 'instantiates' do
        assert_kind_of(Minion, minion)
      end

      describe '#session' do
        let(:session) { MiniTest::NamedMock.new('session') }

        before do
          config.stubs(:ssh_credentials).returns(credentials)
        end

        it 'creates a session' do
          session_constructor.expects(:new).with(fqdn, credentials).returns(session)
          minion.session
        end
      end

      describe '#roles' do
        let(:roles) { %w(foo bar) }
        let (:config_minions) {{ fqdn => { 'roles' => roles } }}

        before do
          config.stubs(:minions).returns(config_minions)
        end

        it 'returns a list of roles' do
          assert_equal(2,minion.roles.count)
          roles.each { |role| assert_includes(minion.roles, role) }
        end
      end
    end
  end
end


