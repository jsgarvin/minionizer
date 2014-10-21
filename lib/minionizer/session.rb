require 'securerandom'
module Minionizer
  class Session
    attr_reader :fqdn, :username, :password, :ssh_connector, :scp_connector, :command_executor

    def initialize(fqdn, credentials, ssh_connector=Net::SSH, scp_connector=Net::SCP, command_executor=CommandExecution)
      @fqdn = fqdn
      @username = credentials['username']
      @password = credentials['password']
      @ssh_connector = ssh_connector
      @scp_connector = scp_connector
      @command_executor = command_executor
    end

    def sudo(*commands)
      @with_sudo = true
      if commands.any?
        return exec(*commands)
      else
        yield self
      end
    ensure
      @with_sudo = false
    end

    def exec(*commands)
      options = commands.last.is_a?(Hash) ? commands.pop : {}
      results = commands.map { |command| execution(command, options).call }
      results.length == 1 ? results.first : results
    end

    def scp(local_path, remote_path)
      if with_sudo?
        tmp_filename = "#{SecureRandom.hex}.minionizer_tempfile"
        scp_connection.upload!(local_path, "#{tmp_filename}")
        exec("mv #{tmp_filename} #{remote_path}")
      else
        scp_connection.upload!(local_path, remote_path)
      end
    end

    #######
    private
    #######

    def execution(command, options={})
      if with_sudo?
        command_executor.new(ssh_connection, prefix_sudo(command), options)
      else
        command_executor.new(ssh_connection, command, options)
      end
    end

    def prefix_sudo(command)
      %Q{sudo bash -c "#{command}"}
    end

    def with_sudo?
      @with_sudo
    end

    def ssh_connection
      @ssh_connection ||= ssh_connector.start(fqdn, username, password: password)
    end

    def scp_connection
      @scp_connection ||= scp_connector.start(fqdn, username, password: password)
    end

  end
end
