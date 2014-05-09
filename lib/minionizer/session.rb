module Minionizer
  class Session
    attr_reader :fqdn, :username, :password, :connector, :command_executor

    def initialize(fqdn, credentials, connector = Net::SSH, command_executor = CommandExecution)
      @fqdn = fqdn
      @username = credentials['username']
      @password = credentials['password']
      @connector = connector
      @command_executor = command_executor
    end

    def sudo(*commands)
      @with_sudo = true
      if commands.any?
        results = commands.map { |command| execution(command).call  }
        return (results.length == 1 ? results.first : results)
      else
        yield self
      end
    ensure
      @with_sudo = false
    end

    def exec(*commands)
      results = commands.map { |command| execution(command).call }
      results.length == 1 ? results.first : results
    end

    #######
    private
    #######

    def execution(command)
      if with_sudo?
        command_executor.new(connection, prefix_sudo(command))
      else
        command_executor.new(connection, command)
      end
    end

    def connection
      @connection ||= connector.start(fqdn, username, password: password)
    end

    def prefix_sudo(command)
      %Q{sudo bash -c "#{command}"}
    end

    def with_sudo?
      @with_sudo
    end

  end
end
