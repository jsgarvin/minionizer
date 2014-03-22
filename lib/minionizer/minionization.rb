module Minionizer
  class Minionization
    attr_reader :arguments, :config, :minion_constructor

    def initialize(arguments, config, minion_constructor = Minion)
      @arguments = arguments
      @config = config
      @minion_constructor = minion_constructor
    end

    def call
      minions.each do |minion|
        minion.roles.each { |name| execute_role(minion.session, name) }
      end
    end

    #######
    private
    #######

    def minions
      if first_argument_is_a_minion?
        [construct_minion(first_argument)]
      else
        minions_for_role(first_argument)
      end
    end

    def execute_role(session, name)
      require role_path(name)
      name.classify.constantize.new(session).call
    end

    def first_argument_is_a_minion?
      config.minions.include?(first_argument)
    end

    def minions_for_role(role_name)
      minion_names_for_role(role_name).map {|name| construct_minion(name) }
    end

    def construct_minion(name)
      minion_constructor.new(name, config)
    end

    def role_path(name)
      File.expand_path("./roles/#{name}.rb")
    end

    def minion_names_for_role(role_name)
      config.minions.keys.select do |minion|
        config.minions[minion]['roles'].include?(role_name)
      end
    end

    def first_argument
      @first_argument ||= arguments.pop
    end
  end
end
