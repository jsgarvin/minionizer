module Minionizer
  class Minion
    attr_reader :config, :fqdn, :session_constructor

    def initialize(fqdn, config, session_constructor = Session)
      @fqdn = fqdn
      @config = config
      @session_constructor = session_constructor
    end

    def session
      @session ||= session_constructor.new(fqdn, ssh_credentials)
    end

    def roles
      my_config['roles']
    end

    #######
    private
    #######

    def ssh_credentials
      {
        'username' => my_config['ssh']['username'],
        'password' => my_config['ssh']['password']
      }
    end

    def my_config
      config.minions[fqdn]
    end
  end
end
