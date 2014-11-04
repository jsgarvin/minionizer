module Minionizer
  class FileInjection < TaskTemplate

    def call
      session.exec("mkdir --parents #{target_directory}")
      session.scp(string_io_creator.new(contents), target_path)
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
      options[:contents] ||= processed_contents_from_source_path
    end

    def processed_contents_from_source_path
      if source_file_requires_erb_processing?
        ERB.new(contents_from_source_path).result(erb_binding)
      else
        contents_from_source_path
      end
    end

    def source_file_requires_erb_processing?
      File.extname(source_path) == '.erb'
    end

    def contents_from_source_path
      File.open(source_path).read
    end

    def erb_binding
      level = 1
      until binding.of_caller(level).eval('self.class') != self.class
        level += 1
      end
      binding.of_caller(level)
    end

    def string_io_creator
      options[:string_io_creator] ||= StringIO
    end
  end
end
