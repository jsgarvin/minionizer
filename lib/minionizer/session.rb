module Minionizer
  class Session
    attr_reader :fqdn, :username, :password, :connector

    def initialize(fqdn, username, password, connector = Net::SSH)
      @fqdn = fqdn
      @username = username
      @password = password
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
