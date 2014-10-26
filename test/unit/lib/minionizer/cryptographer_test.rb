require 'test_helper'

module Minionizer
  class CryptographerTest < MiniTest::Test
    describe Cryptographer do
      let(:cryptographer) { Cryptographer.new }
      let(:unencrypted_filename) { 'foobar.txt' }
      let(:encrypted_filename) { "#{unencrypted_filename}.enc" }
      let(:path_to_unencrypted_filename) { "#{Cryptographer::SECRET_FOLDER}/#{unencrypted_filename}" }
      let(:path_to_encrypted_filename) { "#{Cryptographer::SAFE_FOLDER}/#{encrypted_filename}" }
      let(:path_to_stored_sha) { "#{Cryptographer::SAFE_FOLDER}/#{unencrypted_filename}.sha" }

      before do
        Dir.stubs(:foreach).with(Cryptographer::SECRET_FOLDER).yields(unencrypted_filename)
        Dir.stubs(:foreach).with(Cryptographer::SAFE_FOLDER).yields(encrypted_filename)
        @stdout = $stdout
        $stdout = StringIO.new
      end

      after do
        $stdout = @stdout
      end

      describe '#generate_key' do

        it 'generates a key' do
          cryptographer.expects(:system).with() { |c| c.match(/--gen-key/) }
          cryptographer.generate_key
        end

      end

      describe '#encrypt_secrets' do

        describe 'when remote sha does not exist' do

          before do
            File.expects(:exists?).with(path_to_stored_sha).returns(false)
            cryptographer.stubs(:`).with() { |c| c.match(/--fingerprint/) }.
              returns("fingerprint\n")
            cryptographer.stubs(:system).with() { |c| c.match(/sha512sum/) }
            cryptographer.stubs(:system).with() do |c|
              c.match(/--encrypt #{path_to_unencrypted_filename}/)
            end
          end

          it 'encrypts the file' do
            cryptographer.expects(:system).with() do |c|
              c.match(/--encrypt #{path_to_unencrypted_filename}/)
            end
            cryptographer.encrypt_secrets
          end

          it 'generates the stored sha file' do
            cryptographer.expects(:system).
              with("sha512sum #{path_to_unencrypted_filename} > #{path_to_stored_sha}")
            cryptographer.encrypt_secrets
          end

        end

        describe 'when remote sha exists' do

          before do
            File.expects(:exists?).with(path_to_stored_sha).returns(true)
          end

          describe 'when shas match' do
            before do
              cryptographer.stubs(:`).with("sha512sum #{path_to_unencrypted_filename}").returns('SAMEY')
              cryptographer.stubs(:`).with("cat #{path_to_stored_sha}").returns('SAMEY')
            end

            it 'does not encrypt the file' do
              cryptographer.expects(:system).with() { |c| c.match(/--encrypt/) }.never
              cryptographer.encrypt_secrets
            end

          end

          describe 'when shas do not match' do
            before do
              cryptographer.stubs(:system).with() { |c| c.match(/sha512sum/) }
              cryptographer.stubs(:`).with("sha512sum #{path_to_unencrypted_filename}").
                returns('SAMEY')
              cryptographer.stubs(:`).with("cat #{path_to_stored_sha}").returns('NOTSAMEY')
              cryptographer.stubs(:`).with() { |c| c.match(/--fingerprint/) }.
                returns("fingerprint\n")
              cryptographer.stubs(:system).with() { |c| c.match(/--encrypt/) }
            end

            it 'encrypts the file' do
              cryptographer.expects(:system).with() do |c|
                c.match(/--encrypt #{path_to_unencrypted_filename}/)
              end
              cryptographer.encrypt_secrets
           end

            it 'generates the stored sha file' do
             cryptographer.expects(:system).
                with("sha512sum #{path_to_unencrypted_filename} > #{path_to_stored_sha}")
              cryptographer.encrypt_secrets
            end

          end
        end
      end

      describe '#decrypt_secrets' do
        describe 'when shas match' do

          before do
            File.expects(:exists?).with(path_to_stored_sha).returns(true)
            cryptographer.stubs(:`).with("sha512sum #{path_to_unencrypted_filename}").
              returns('SAMEY')
            cryptographer.stubs(:`).with("cat #{path_to_stored_sha}").returns('SAMEY')
          end

          it 'does not excrypt the file' do
            cryptographer.expects(:system).with() { |c| c.match(/--decrypt/) }.never
            cryptographer.decrypt_secrets
          end
        end

        describe 'when shas do not match' do

          before do
            cryptographer.stubs(:`).with("sha512sum #{path_to_unencrypted_filename}").
              returns('SAMEY')
            cryptographer.stubs(:`).with("cat #{path_to_stored_sha}").returns('NOTSAMEY')
          end

          it 'decrypts the file' do
            cryptographer.expects(:system).with() do |c|
              c.match(/--decrypt #{path_to_encrypted_filename}/)
            end
            cryptographer.decrypt_secrets
          end
        end
      end

    end
  end
end

