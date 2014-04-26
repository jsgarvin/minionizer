module Minionizer
  class FolderCreation < TaskTemplate

    def call
      session.exec("mkdir --parents --verbose '#{path}'")
    end

  end
end
