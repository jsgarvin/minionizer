module Minionizer
  class FolderCreation < TaskTemplate

    def call
      session.exec("mkdir --parents #{path}")
      session.exec("chmod #{mode} #{path}")
    end

  end
end
