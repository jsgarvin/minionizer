module Minionizer
  class FileInjection < TaskTemplate

    def call
      session.exec("echo '#{contents_from(source_path)}' > #{target_path}")
      session.exec("chmod #{mode} #{target_path}") if respond_to?(:mode)
      session.exec("chown #{owner} #{target_path}") if respond_to?(:owner)
      session.exec("chgrp #{group} #{target_path}") if respond_to?(:group)
    end

    #######
    private
    #######

    def contents_from(source)
      File.open(source).read.strip
    end
  end
end
