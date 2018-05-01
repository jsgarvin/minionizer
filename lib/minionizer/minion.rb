module Minionizer
  class Minion
    attr_reader :config, :fqdn, :session_constructor

    def initialize(fqdn, config, session_constructor = Session)
      @fqdn = fqdn
      @config = config.minions[fqdn]
      @session_constructor = session_constructor
    end

    def session
      @session ||= session_constructor.new(self)
    end

    def roles
      config['roles']
    end
  end
end
