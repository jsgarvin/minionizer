module Minionizer
  class FolderCreation < TaskTemplate

    def call
      session.exec("mkdir --parents #{path}")
      session.exec("chmod #{mode} #{path}") if respond_to?(:mode)
      session.exec("chown #{owner} #{path}") if respond_to?(:owner)
      session.exec("chgrp #{group} #{path}") if respond_to?(:group)
    end

  end
end
