module Minionizer
  class RoleTemplate
    attr_reader :session

    def initialize(session)
      @session = session
    end

    def call
      raise StandardError.new('call method must be defined by inheriting role.')
    end
  end
end
