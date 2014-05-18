require 'test_helper'

module Minionizer
  class PublicSshKeyInjectionTest < MiniTest::Test

    describe PublicSshKeyInjection do

      describe '#call' do
        let(:key) { 'foobar' }
        let(:file_injection) { mock('file_injecton') }
        let(:folder_creation) { mock('folder_creation') }
        let(:file_injection_creator) { mock('FileInjection') }
        let(:folder_creation_creator) { mock('FolderCreation') }
        let(:session) { 'MockSession' }
        let(:username) { 'foouser' }
        let(:key_injection_options) {{
          target_username: username,
          file_injection_creator: file_injection_creator,
          folder_creation_creator: folder_creation_creator
        }}
        let(:key_injection) { PublicSshKeyInjection.new(session, key_injection_options) }
        let(:expected_folder_creation_options) {[
          session,
          {
            :path => "/home/#{username}/.ssh",
            :owner => username,
            :group => username,
            mode: 700
          }
        ]}
        let(:expected_file_injection_options) {[
          session,
          {
            :contents => key,
            :target_path => "/home/#{username}/.ssh/authorized_keys",
            :owner => username,
            :group => username,
            mode: 600
          }
        ]}

        before do
          write_file('data/public_keys/foobar.pubkey', 'foobar')
        end

        it 'injects the file' do
          folder_creation_creator.expects(:new).with(*expected_folder_creation_options).returns(folder_creation)
          folder_creation.expects(:call)
          file_injection_creator.expects(:new).with(*expected_file_injection_options).returns(file_injection)
          file_injection.expects(:call)

          key_injection.call
        end
      end
    end
  end
end
