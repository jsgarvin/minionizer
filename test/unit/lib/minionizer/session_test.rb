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

        describe '#sudo' do
          let(:stdout_data) { 'stdout' }
          let(:stderr_data) { 'stderr' }
          let(:exit_code) { 0 }
          let(:exit_signal) { 'exit_signal' }

          before do
            connection.expects(:open_channel).yields(channel)
            channel.expects(:on_data).yields(nil, stdout_data)
            channel.expects(:on_extended_data).yields(nil, stderr_data)
            channel.expects(:on_request).with('exit-status').yields(nil, OpenStruct.new(:read_long => exit_code))
            channel.expects(:on_request).with('exit-signal').yields(nil, OpenStruct.new(:read_long => exit_signal))
            connection.expects(:loop)
          end

          describe 'with block argument' do

            it 'prepends sudo onto the command line' do
              channel.expects(:exec).with(sudoized(command)).yields(channel, true)
              session.sudo do
                session.exec(command)
              end
            end
          end

          describe 'with single command passed directly' do
            it 'prepends sudo onto the command line' do
              channel.expects(:exec).with(sudoized(command)).yields(channel, true)
              session.sudo(command)
            end
          end

          describe 'with multiple commands passed directly' do
            let(:commands) { %w{foo bar} }

            before do
              #expect these calls again
              connection.expects(:open_channel).yields(channel)
              channel.expects(:on_data).yields(nil, stdout_data)
              channel.expects(:on_extended_data).yields(nil, stderr_data)
              channel.expects(:on_request).with('exit-status').yields(nil, OpenStruct.new(:read_long => exit_code))
              channel.expects(:on_request).with('exit-signal').yields(nil, OpenStruct.new(:read_long => exit_signal))
              connection.expects(:loop)
            end

            it 'prepends sudo onto each command line' do
              commands.each do |command|
                channel.expects(:exec).with(sudoized(command)).yields(channel, true)
              end
              session.sudo(*commands)
            end
          end

        end

        describe 'when a single command is passed' do
          let(:stdout_data) { 'stdout' }
          let(:stderr_data) { 'stderr' }
          let(:exit_signal) { 'exit_signal' }

          before do
            connection.expects(:open_channel).yields(channel)
            connection.expects(:loop)
            channel.expects(:exec).with(command).yields(channel, true)
            channel.expects(:on_data).yields(nil, stdout_data)
            channel.expects(:on_extended_data).yields(nil, stderr_data)
            channel.expects(:on_request).with('exit-status').yields(nil, OpenStruct.new(:read_long => exit_code))
            channel.expects(:on_request).with('exit-signal').yields(nil, OpenStruct.new(:read_long => exit_signal))
          end

          describe 'when exit code is 0' do
            let(:exit_code) { 0 }

            before do
              @result = session.exec(command)
            end

            it 'returns a single result' do
              assert_equal(stdout_data, @result[:stdout])
              assert_equal(stderr_data, @result[:stderr])
              assert_equal(exit_code, @result[:exit_code])
              assert_equal(exit_signal, @result[:exit_signal])
            end

          end

          describe 'when exit code is not 0' do
            let(:exit_code) { 1 }

            it 'raises StandardError' do
              assert_raises(CommandError) do
                @result = session.exec(command)
              end
            end

          end

        end

        describe 'when multiple commands are passed' do
          let(:commands) { %w{foo bar} }

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
