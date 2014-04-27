require 'test_helper'

module Minionizer
  class SessionTest < MiniTest::Unit::TestCase

    describe Session do
      let(:fqdn) { 'foo.bar.com' }
      let(:username) { 'foo' }
      let(:password) { 'bar' }
      let(:credentials) {{ 'username' => username, 'password' => password }}
      let(:connector) { mock('connector') }
      let(:channel) { mock('channel') }
      let(:connection) { mock('connection') }
      let(:channel) { mock('channel') }
      let(:session) { Session.new(fqdn, credentials, connector) }
      let(:start_args) { [fqdn, username, { password: password }]}

      it 'instantiates' do
        assert_kind_of(Session, session)
      end

      describe 'running commands' do
        let(:command) { 'foobar' }

        before do
          connector.expects(:start).with(*start_args).returns(connection)
        end

        describe 'when a single command is passed' do

          before do
            connection.expects(:open_channel).yields(channel)
            connection.expects(:loop).returns('fixme')
            channel.expects(:exec).with(command).returns("#{command} pong")
          end

          it 'returns a single result' do
            assert_kind_of(Hash, session.exec(command))
          end
        end

        describe 'when multiple commands are passed' do
          let(:commands) { %w(foo bar) }

          before do
            connection.expects(:open_channel).twice.yields(channel)
            commands.each do |command|
              channel.expects(:exec).with(command).returns("#{command} pong")
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
