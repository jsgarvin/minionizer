module Minionizer
  class FileInjection < TaskTemplate

    def call
      session.exec("echo '#{contents_from(source_path)}' > #{target_path}")
    end

    #######
    private
    #######

    def contents_from(source)
      File.open(source).read.strip
    end
  end
end
