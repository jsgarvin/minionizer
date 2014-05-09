require 'test_helper'

module Minionizer
  class CommandExecutionTest < MiniTest::Unit::TestCase

    describe CommandExecution do
      let(:command) { 'foo --bar' }
      let(:connection) { 'MockConnection' }
      let(:execution) { CommandExecution.new(connection, command) }

      describe '#call' do
        let(:channel) { 'MockChannel' }
        let(:stdout_data) { 'stdout' }
        let(:stderr_data) { 'stderr' }
        let(:exit_code) { 0 }
        let(:exit_signal) { 'exit_signal' }

        before do
          connection.stubs(:open_channel).yields(channel)
          channel.stubs(:on_data).yields(nil, stdout_data)
          channel.stubs(:on_extended_data).yields(nil, stderr_data)
          channel.
            stubs(:on_request).
            with('exit-status').
            yields(nil, OpenStruct.new(:read_long => exit_code))
          channel.
            stubs(:on_request).
            with('exit-signal').
            yields(nil, OpenStruct.new(:read_long => exit_signal))
          connection.stubs(:loop)
        end

        describe 'command runs successfully' do

          before do
            channel.
              expects(:exec).
              with(command).
              yields(channel, true)
          end

          it 'runs the command' do
            execution.call
          end

        end

        describe 'command fails to be invoked' do

          before do
            channel.
              expects(:exec).
              with(command).
              yields(channel, false)
          end

          it 'raises InvocationError' do
            assert_raises(CommandExecution::InvocationError) do
              execution.call
            end
          end

        end

        describe 'command returns non-zero exit status' do
          let(:exit_code) { 1 }

          before do
            channel.
              expects(:exec).
              with(command).
              yields(channel, true)
          end

          it 'raises CommandError' do
            assert_raises(CommandExecution::CommandError) do
              execution.call
            end
          end
        end
      end
    end
  end
end

