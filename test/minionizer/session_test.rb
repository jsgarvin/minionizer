require 'test_helper'

module Minionizer
  class SessionTest < MiniTest::Unit::TestCase

    describe Session do
      let(:fqdn) { 'foo.bar.com' }
      let(:username) { 'foo' }
      let(:password) { 'bar' }
      let(:connector) { MiniTest::Mock.new }
      let(:channel) { MiniTest::Mock.new }
      let(:connection) { MiniTest::Mock.new }
      let(:session) { Session.new(fqdn, username, password, connector) }

      it 'instantiates' do
        assert_kind_of(Session, session)
      end

      describe 'opening a connection' do
        let(:commands) { %w(foo bar) }

        it 'starts the connector' do
          connector.expect(:start, connection, [fqdn, username, {password: password}])
          connection.expect(:open_channel, channel)
          commands.each {|command| channel.expect(:exec, true, [command]) }
          session.exec(commands)
        end
      end

    end
  end
end
