module Minionizer
  class Session
    attr_reader :fqdn, :username, :password, :connector

    def initialize(fqdn, credentials, connector = Net::SSH)
      @fqdn = fqdn
      @username = credentials[:username]
      @password = credentials[:password]
      @connector = connector
    end

    def exec(*commands)
      connection.open_channel do |channel|
        commands.each do |command|
          channel.exec(command)
        end
      end
    end

    #######
    private
    #######

    def connection
      @connection ||= connector.start(fqdn, username, password: password)
    end
  end
end
