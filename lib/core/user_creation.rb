module Minionizer
  class UserCreation < TaskTemplate

    def call
      session.exec("sudo adduser --disabled-password --gecos '#{name}' #{username}")
    end
  end
end
