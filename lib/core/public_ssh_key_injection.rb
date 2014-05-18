module Minionizer
  class PublicSshKeyInjection < TaskTemplate

    def call
      folder_creation.call
      file_injection.call
    end

    #######
    private
    #######

    def folder_creation
      @folder_creation ||= folder_creation_creator.new(session, folder_creation_options)
    end

    def file_injection
      @file_injection ||= file_injection_creator.new(session, file_injection_options)
    end

    def folder_creation_creator
      options[:folder_creation_creator] ||= FolderCreation
    end

    def file_injection_creator
      options[:file_injection_creator] ||= FileInjection
    end

    def folder_creation_options
      {
        path: target_folder,
        owner: target_username,
        group: target_username,
        mode: 700
      }
    end

    def file_injection_options
      {
        contents: combined_keys,
        target_path: "#{target_folder}/authorized_keys",
        owner: target_username,
        group: target_username,
        mode: 600
      }
    end

    def target_folder
      "/home/#{target_username}/.ssh"
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
