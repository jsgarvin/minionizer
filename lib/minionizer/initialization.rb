module Minionizer
  class Initialization
    SUBFOLDERS = [
      '', #root folder
      '/config',
      '/data/encrypted_secrets',
      '/data/public_keys',
      '/data/secrets',
      '/lib',
      '/roles'
    ]

    attr_reader :path

    def self.create(path)
      new(path).save
    end

    def initialize(path)
      @path = path
    end

    def save
      create_directory_structure
      touch_config
      ignore_secrets
    end

    private

    def create_directory_structure
      SUBFOLDERS.each do |folder|
        system("mkdir -p #{path}#{folder}")
      end
    end

    def touch_config
      system("touch #{path}/config/minions.yml")
    end

    def ignore_secrets
      system("touch #{gitignore_path}")
      system("echo 'data/secrets' > #{gitignore_path}") unless secrets_ignored?
    end

    def secrets_ignored?
      File.readlines(gitignore_path).grep(/^data\/secrets$/).any?
    end

    def gitignore_path
      "#{path}/.gitignore"
    end

  end
end
