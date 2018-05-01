require 'test_helper'

module Minionizer
  class MinionTest < MiniTest::Test
    describe Minion do
      let(:username) { 'foo' }
      let(:password) { 'bar' }
      let(:credentials) {{ 'username' => username, 'password' => password }}
      let(:config) { Configuration.instance }
      let(:fqdn) { 'foo.bar.com' }
      let(:session_constructor) { quacks_like(Session) }
      let(:minion) { Minion.new(fqdn, config, session_constructor) }
      let(:roles) { %w(foo bar) }
      let (:minion_config) {{ fqdn => { 'roles' => roles , 'ssh' => credentials } }}

      before do
        config.stubs(:minions).returns(minion_config)
      end

      it 'instantiates' do
        assert_kind_of(Minion, minion)
      end

      describe '#session' do
        let(:session) { quacks_like_instance_of(Session) }

        it 'creates a session' do
          session_constructor.expects(:new).with(minion).returns(session)
          minion.session
        end
      end

      describe '#roles' do

        it 'returns a list of roles' do
          assert_equal(2,minion.roles.count)
          roles.each { |role| assert_includes(minion.roles, role) }
        end
      end
    end
  end
end
