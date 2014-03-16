require 'test_helper'

module Minionizer
  class SessionTest < MiniTest::Unit::TestCase

    describe Session do
      let(:fqdn) { 'foo.bar.com' }
      let(:username) { 'foo' }
      let(:password) { 'bar' }
      let(:credentials) {{ username: username, password: password }}
      let(:connector) { MiniTest::Mock.new }
      let(:channel) { MiniTest::Mock.new }
      let(:connection) { MiniTest::Mock.new }
      let(:session) { Session.new(fqdn, credentials, connector) }

      it 'instantiates' do
        assert_kind_of(Session, session)
      end

      describe 'opening a connection' do
        let(:commands) { %w(foo bar) }
        let(:start_args) { [fqdn, username, { password: password }]}

        it 'starts the connector' do
          connector.expect(:start, connection, start_args)
          connection.expect(:open_channel, channel)
          commands.each {|command| channel.expect(:exec, true, [command]) }
          session.exec(commands)
        end
      end

    end
  end
end
