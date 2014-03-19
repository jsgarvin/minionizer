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
      connection.open_channel do |channel|
        commands.each do |command|
          channel.exec(command) do |x, s|
            channel.on_data do |z, a|
              puts a
            end
          end
        end
      end
      connection.loop
    end

    #######
    private
    #######

    def connection
      puts "Opening Connection: #{fqdn}:#{username}:#{password}"
      @connection ||= connector.start(fqdn, username, password: password)
    end
  end
end
