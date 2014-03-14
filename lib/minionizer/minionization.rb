module Minionizer
  class Minionization
    attr_reader :arguments, :config

    def initialize(arguments, config)
      @arguments = arguments
      @config = config
    end

    def call
      if roles_exist?
        execute_roles
      else
        raise Minionizer::Errors::MissionNotFound.new("Failed to locate file #{mission_path}")
      end
    end

    #######
    private
    #######

    def roles_exist?
      missing_roles.empty?
    end

    def missing_roles
      roles.select { |role| ! role_exists?(role) }
    end

    def roles
      @roles ||= config.minions[minion]['roles']
    end

    def role_exists?(role)
      File.exists?(role_path(role))
    end

    def execute_roles
      roles.each { |role| require role_path(role) }
    end

    def role_path(role)
      File.expand_path("./roles/#{role}.rb")
    end

    def minion
      @first_argument ||= arguments.pop
    end
  end
end
