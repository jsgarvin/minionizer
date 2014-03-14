module Minionizer
  class Minionization
    attr_reader :arguments

    def initialize(arguments)
      @arguments = arguments
    end

    def call
      if mission_exists?
        execute_mission
      else
        raise Minionizer::Errors::MissionNotFound.new("Failed to locate file #{mission_path}")
      end
    end

    #######
    private
    #######

    def mission_exists?
      File.exists?(mission_path)
    end

    def execute_mission
      require mission_path
    end

    def mission_path
      File.expand_path("./missions/#{first_argument}.rb")
    end

    def first_argument
      @first_argument ||= arguments.pop
    end
  end
end
