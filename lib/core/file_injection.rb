module Minionizer
  class FileInjection
    attr_reader :session

    def initialize(session)
      @session = session
    end

    def inject(source, target)
      session.exec("echo '#{contents_from(source)}' > #{target}")
    end

    #######
    private
    #######

    def contents_from(source)
      File.open(source).read.strip
    end
  end
end
