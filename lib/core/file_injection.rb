module Minionizer
  class FileInjection < TaskTemplate

    def call
      session.exec("mkdir --parents #{target_directory}")
      session.exec("echo '#{contents}' > #{target_path}")
      session.exec("chmod #{mode} #{target_path}") if respond_to?(:mode)
      session.exec("chown #{owner} #{target_path}") if respond_to?(:owner)
      session.exec("chgrp #{group} #{target_path}") if respond_to?(:group)
    end

    #######
    private
    #######

    def target_directory
      File.dirname(target_path)
    end

    def contents
      options[:contents] ||= contents_from_source_path
    end

    def contents_from_source_path
      File.open(source_path).read.strip
    end
  end
end
