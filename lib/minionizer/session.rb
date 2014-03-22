module Minionizer
  class Session
    attr_reader :fqdn, :username, :password, :connector

    def initialize(fqdn, credentials, connector = Net::SSH)
      @fqdn = fqdn
      @username = credentials['username']
      @password = credentials['password']
      @connector = connector
    end

    def exec(*commands)
      commands.map do |command|
        exec_single_command(command)
      end
    end

    #######
    private
    #######

    def exec_single_command(command)
      connection.exec(command) do |channel, stream, output|
        if stream == :stdout
          return output.strip
        else
          raise StandardError.new(output)
        end
      end
      connection.loop
    end

    def connection
      @connection ||= connector.start(fqdn, username, password: password)
    end
  end
end
