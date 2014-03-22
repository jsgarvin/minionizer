require 'test_helper'

module Minionizer
  class SessionTest < MiniTest::Unit::TestCase

    describe Session do
      let(:fqdn) { 'foo.bar.com' }
      let(:username) { 'foo' }
      let(:password) { 'bar' }
      let(:credentials) {{ 'username' => username, 'password' => password }}
      let(:connector) { MiniTest::NamedMock.new(:connector) }
      let(:channel) { MiniTest::NamedMock.new(:channel) }
      let(:connection) { MiniTest::NamedMock.new(:connection) }
      let(:session) { Session.new(fqdn, credentials, connector) }

      it 'instantiates' do
        assert_kind_of(Session, session)
      end

      describe 'opening a connection' do
        let(:commands) { %w(foo bar) }
        let(:start_args) { [fqdn, username, { password: password }]}

        it 'starts the connector' do
          connector.expect(:start, connection, start_args)
          connection.expect(:exec, true, [commands])
          connection.expect(:loop, true)
          commands.each {|command| channel.expect(:exec, true, [command]) }
          session.exec(commands)
        end
      end

    end
  end
end
