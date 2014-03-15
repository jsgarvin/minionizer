module Minionizer
  class Minionization
    attr_reader :arguments, :config

    def initialize(arguments, config)
      @arguments = arguments
      @config = config
    end

    def call
      execute_roles
    end

    #######
    private
    #######

    def execute_roles
      minions.each do |minion|
        role_names(minion).each { |name| execute_role(name) }
      end
    end

    def role_names(minion)
      @role_names ||= config.minions[minion]['roles']
    end

    def execute_role(name)
      require role_path(name)
      name.classify.constantize.new.call(self)
    end

    def role_path(name)
      File.expand_path("./roles/#{name}.rb")
    end

    def minions
      if first_argument_is_a_minion?
        [first_argument]
      else
        minions_for_role(first_argument)
      end
    end

    def first_argument_is_a_minion?
      config.minions.include?(first_argument)
    end

    def minions_for_role(role_name)
     config.minions.keys.select do |minion|
       config.minions[minion]['roles'].include?(role_name)
     end
    end

    def first_argument
      @first_argument ||= arguments.pop
    end
  end
end
