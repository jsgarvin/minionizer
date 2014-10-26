module Minionizer
  class Cryptographer
    KEYRING_PATH = './data/public_keyring.gpg'
    SECRET_FOLDER  = './data/secrets'
    SAFE_FOLDER  = './data/encrypted_secrets'

    def generate_key
      system("#{gpg_command} --gen-key")
    end

    def encrypt_secrets
      Dir.foreach(SECRET_FOLDER) do |filename|
        next if ['.','..'].include?(filename)
        encrypt_and_rehash(filename)
      end
    end

    def decrypt_secrets
      Dir.foreach(SAFE_FOLDER) do |filename|
        next unless filename.match(/\.enc$/)
        decrypt(filename)
      end
    end

    private

    def encrypt_and_rehash(filename)
      if shas_match?(filename)
        puts "Skipping: #{filename} (shas match)"
      else
        puts "Encrypting: #{filename}"
        system("#{gpg_command} --output #{SAFE_FOLDER}/#{filename}.enc #{recipient_args.join(' ')} --encrypt #{SECRET_FOLDER}/#{filename}")
        hash(filename)
      end
    end

    def hash(filename)
      puts "Hashing: #{filename}"
      system("sha512sum #{SECRET_FOLDER}/#{filename} > #{SAFE_FOLDER}/#{filename}.sha")
    end

    def decrypt(filename)
      if shas_match?(decrypted_filename(filename))
        puts "Skipping: #{filename} (shas match)"
      else
        puts "Decrypting: #{filename}"
        system("#{gpg_command} --output #{SECRET_FOLDER}/#{decrypted_filename(filename)} --decrypt #{SAFE_FOLDER}/#{filename}")
      end
    end

    def recipient_args
      recipient_fingerprints.split("\n").map {|fingerprint| "--recipient #{fingerprint}" }
    end

    def recipient_fingerprints
      "fingerprint\n"
      `#{gpg_command} --fingerprint --with-colons | grep fpr | cut -d ":" -f10`
    end

    def decrypted_filename(filename)
      filename.match(/(.+)\.enc$/)[1]
    end

    def gpg_command
      "gpg --keyring #{KEYRING_PATH} --no-default-keyring"
    end

    def shas_match?(filename)
      File.exists?(stored_sha_path(filename)) && local_sha(filename) == stored_sha(filename)
    end

    def local_sha(filename)
      `sha512sum #{SECRET_FOLDER}/#{filename}`
    end

    def stored_sha(filename)
      `cat #{stored_sha_path(filename)}`
    end

    def stored_sha_path(filename)
      "#{SAFE_FOLDER}/#{filename}.sha"
    end
  end
end
