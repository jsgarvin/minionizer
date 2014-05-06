module Minionizer
  class UserCreation < TaskTemplate

    def call
      session.exec("adduser --disabled-password --gecos '#{name}' #{username}")
    end
  end
end
