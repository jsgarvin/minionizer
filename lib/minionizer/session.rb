module Minionizer
  class Session
    attr_reader :fqdn, :username, :password, :connector

    def initialize(fqdn, credentials, connector = Net::SSH)
      @fqdn = fqdn
      @username = credentials['username']
      @password = credentials['password']
      @connector = connector
    end

    def exec(arg)
      if arg.is_a?(Array)
        arg.map { |command| exec_single_command(command) }
      else
        exec_single_command(arg)
      end
    end

    #######
    private
    #######

    def exec_single_command(command)
      {stdout: '', stderr: ''}.tap do |result|
        connection.open_channel do |channel|
          channel.exec(command) do |_, success|
            raise StandardError.new('Not success') unless success
            channel.on_data { |_, data| result[:stdout] += data.strip }
            channel.on_extended_data { |_, data| result[:stderr] += data.to_s }
            channel.on_request('exit-status') { |_,data| result[:exit_code] = data.read_long }
            channel.on_request('exit-signal') { |_,data| result[:exit_signal] = data.read_long }
          end
        end
        connection.loop
        unless result[:exit_code].to_i == 0
          raise StandardError.new("Command \"#{command}\" returned exit code #{result[:exit_code]}/#{result[:exit_signal]}/#{result[:stderr]}")
        end
      end
    end

    def connection
      @connection ||= connector.start(fqdn, username, password: password)
    end
  end
end
