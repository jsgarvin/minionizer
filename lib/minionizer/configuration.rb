module Minionizer
  class Configuration
    include Singleton

    def minions
      @minions ||= YAML::load_file('./config/minions.yml')
    end
  end
end

