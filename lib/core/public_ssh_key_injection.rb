module Minionizer
  class PublicSshKeyInjection < TaskTemplate

    def call
      file_injection.call
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
        contents: combined_keys,
        target_path: "~#{target_username}/.ssh/authorized_keys",
        owner: target_username,
        group: target_username
      }
    end

    def combined_keys
      String.new.tap do |string|
        Dir.glob("data/public_keys/*.pubkey") do |key_file|
          string << File.open(key_file).read
        end
      end
    end

  end
end
