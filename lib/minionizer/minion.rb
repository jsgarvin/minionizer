module Minionizer
  class Minion
    attr_reader :config, :fqdn, :session_constructor

    def initialize(fqdn, config, session_constructor = Session)
      @fqdn = fqdn
      @config = config
      @session_constructor = session_constructor
    end

    def session
      @session ||= session_constructor.new(fqdn, config.ssh_credentials)
    end

    def roles
      config.minions[fqdn]['roles']
    end

  end
end
