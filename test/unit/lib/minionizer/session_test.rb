require 'test_helper'

module Minionizer
  class SessionTest < MiniTest::Test

    describe Session do
      let(:fqdn) { 'foo.bar.com' }
      let(:username) { 'foo' }
      let(:password) { 'bar' }
      let(:credentials) {{ 'username' => username, 'password' => password }}
      let(:ssh_connector) { mock('ssh_connector') }
      let(:scp_connector) { mock('scp_connector') }
      let(:command_executor) { mock('CommandExecution') }
      let(:execution) { mock('execution') }
      let(:ssh_connection) { mock('ssh_connection') }
      let(:scp_connection) { mock('scp_connection') }
      let(:session) { Session.new(fqdn, credentials, ssh_connector, scp_connector, command_executor) }
      let(:start_args) { [fqdn, username, { password: password }]}

      it 'instantiates' do
        assert_kind_of(Session, session)
      end

      describe '#scp' do
        let(:source_path) { '/source/path' }
        let(:target_path) { '/target/path' }

        before do
          scp_connector.expects(:start).with(*start_args).returns(scp_connection)
        end

        describe 'straight scp' do

          it 'copies the file to the target location' do
            scp_connection.expects(:upload!).with(source_path, target_path)
            session.scp(source_path, target_path)
          end

        end

        describe 'within sudo block' do
          let(:hex) { 'securehex' }
          let(:temp_filename) { "#{hex}.minionizer_tempfile" }

          before do
            ssh_connector.expects(:start).with(*start_args).returns(ssh_connection)
            SecureRandom.expects(:hex).returns(hex)
          end

          it 'copies the file to temp location and then moves it' do
            scp_connection.expects(:upload!).with(source_path, temp_filename)
            command_executor.
              expects(:new).
              with(ssh_connection, sudoized("mv #{temp_filename} #{target_path}")).
              returns(OpenStruct.new(:call => true))
            session.sudo do |sudo_session|
              sudo_session.scp(source_path, target_path)
            end
          end

        end
      end

      describe 'running commands' do
        let(:command) { 'foobar' }

        before do
          ssh_connector.expects(:start).with(*start_args).returns(ssh_connection)
        end

        describe '#sudo' do

          describe 'with block argument' do

            it 'prepends sudo onto the command line' do
              command_executor.
                expects(:new).
                with(ssh_connection, sudoized(command)).
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
                with(ssh_connection, sudoized(command)).
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
                  with(ssh_connection, sudoized(command)).
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
              with(ssh_connection, command).
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
                with(ssh_connection, command).
                returns(OpenStruct.new(:call => true))
            end
            session.exec(*commands)
          end
        end

      end

    end
  end
end
