module Minionizer
  class PublicSshKeyInjection < TaskTemplate

    def call
      file_injection.call
    ensure
      temp_file.unlink
    end

    #######
    private
    #######

    def file_injection
      @file_injection ||= file_injection_creator.new(session, file_injection_options)
    end

    def file_injection_creator
      options[:file_injection_creator] ||= FileInjection
    end

    def file_injection_options
      {
        source_path: temp_file.path,
        target_path: "~#{target_username}/.ssh/authorized_keys",
        owner: target_username,
        group: target_username
      }
    end

    def temp_file
      @temp_file ||= Tempfile.new('MinionizerPublicKeys').tap do |temp_file|
        Dir.glob("data/public_keys/*.pubkey") do |key_file|
          temp_file.puts File.open(key_file).read
        end
      end
    end

  end
end
