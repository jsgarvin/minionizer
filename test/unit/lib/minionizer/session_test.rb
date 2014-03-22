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
      let(:connection) { 'MockConnection' }
      let(:session) { Session.new(fqdn, credentials, connector) }
      let(:start_args) { [fqdn, username, { password: password }]}

      it 'instantiates' do
        assert_kind_of(Session, session)
      end

      describe 'running commands' do
        let(:command) { 'foobar' }

        before do
          connector.expect(:start, connection, start_args)
        end

        describe 'when a single command is passed' do

          before do
            connection.expects(:exec).with(command).returns("#{command} pong")
            connection.expects(:loop).returns('fixme')
          end

          it 'returns a single result' do
            assert_kind_of(String, session.exec(command))
          end
        end

        describe 'when multiple commands are passed' do
          let(:commands) { %w(foo bar) }

          before do
            commands.each do |command|
              connection.expects(:exec).with(command).returns("#{command} pong")
            end
            connection.expects(:loop).twice.returns('fixme')
          end

          it 'returns multiple results' do
            assert_kind_of(Array, session.exec(commands))
          end
        end

      end

    end
  end
end
