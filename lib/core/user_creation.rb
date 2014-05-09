module Minionizer
  class UserCreation < TaskTemplate

    def call
      unless user_exists?
        session.exec("adduser --disabled-password --gecos '#{name}' #{username}")
      end
    end

    private

    def user_exists?
      session.exec("id #{username}")
    rescue CommandExecution::CommandError
      return false
    end
  end
end
