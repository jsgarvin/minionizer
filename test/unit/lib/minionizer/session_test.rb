require 'test_helper'

module Minionizer
  class SessionTest < MiniTest::Test

    describe Session do
      let(:fqdn) { 'foo.bar.com' }
      let(:username) { 'foo' }
      let(:password) { 'bar' }
      let(:credentials) {{ 'username' => username, 'password' => password }}
      let(:connector) { mock('connector') }
      let(:command_executor) { mock('CommandExecution') }
      let(:execution) { mock('execution') }
      let(:connection) { mock('connection') }
      let(:session) { Session.new(fqdn, credentials, connector, command_executor) }
      let(:start_args) { [fqdn, username, { password: password }]}

      it 'instantiates' do
        assert_kind_of(Session, session)
      end

      describe 'running commands' do
        let(:command) { 'foobar' }

        before do
          connector.expects(:start).with(*start_args).returns(connection)
        end

        describe '#sudo' do

          describe 'with block argument' do

            it 'prepends sudo onto the command line' do
              command_executor.
                expects(:new).
                with(connection, sudoized(command)).
                returns(OpenStruct.new(:call => true))
              session.sudo do
                session.exec(command)
              end
            end
          end

          describe 'with single command passed directly' do

            it 'prepends sudo onto the command line' do
              command_executor.
                expects(:new).
                with(connection, sudoized(command)).
                returns(OpenStruct.new(:call => true))
              session.sudo(command)
            end

          end

          describe 'with multiple commands passed directly' do
            let(:commands) { %w{foo bar} }

            it 'prepends sudo onto each command line' do
              commands.each do |command|
                command_executor.
                  expects(:new).
                  with(connection, sudoized(command)).
                  returns(OpenStruct.new(:call => true))
              end
              session.sudo(*commands)
            end
          end

        end

        describe 'when a single command is passed' do

          let(:exit_code) { 0 }

          it 'passes the command to the executor' do
            command_executor.
              expects(:new).
              with(connection, command).
              returns(OpenStruct.new(:call => true))
            session.exec(command)
          end

        end

        describe 'when multiple commands are passed' do
          let(:commands) { %w{foo bar} }

          it 'passes each command individually to the executor' do
            commands.each do |command|
              command_executor.
                expects(:new).
                with(connection, command).
                returns(OpenStruct.new(:call => true))
            end
            session.exec(*commands)
          end
        end

      end

    end
  end
end
