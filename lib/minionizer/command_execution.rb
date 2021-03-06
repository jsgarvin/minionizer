module Minionizer

  class CommandExecution
    class CommandError < StandardError; end
    class InvocationError < StandardError; end

    attr_reader :connection, :command, :options

    def initialize(connection, command, options={})
      @connection = connection
      @command = command
      @options = options
    end

    def call
      execute_command
      check_exit_code
      return results
    end

    private

    def execute_command
      connection.open_channel do |channel|
        execute_command_inside_channel(channel)
      end
      connection.loop
    end

    def execute_command_inside_channel(channel)
      inform("Running: #{command}")
      channel.exec(command) do |_, success|
        if success
          compile_results(channel)
        else
          raise InvocationError.new("Failed to invoke command: #{command} ")
        end
      end
    end

    def check_exit_code
      if exit_failure?
        raise CommandError.new("\"#{command}\" returned exit code #{results[:exit_code]}/#{results[:exit_signal]}/#{results[:stderr]}")
      end
    end

    def exit_failure?
      results[:exit_code].to_i != 0
    end

    def results
      @results ||= {stdout: '', stderr: ''}
    end

    def compile_results(channel)
      read_stdout(channel)
      channel.on_extended_data { |_, _, data| results[:stderr] += data.to_s }
      channel.on_request('exit-status') { |_,data| results[:exit_code] = data.read_long }
      channel.on_request('exit-signal') { |_,data| results[:exit_signal] = data.read_string }
    end

    def read_stdout(channel)
      channel.on_data do |_, data|
        inform("STDOUT: #{data}")
        results[:stdout] += data.strip
      end
    end

    def inform(message)
      puts message if options[:verbose]
    end
  end
end
