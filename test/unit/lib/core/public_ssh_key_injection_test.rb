require 'test_helper'

module Minionizer
  class PublicSshKeyInjectionTest < MiniTest::Test

    describe PublicSshKeyInjection do

      describe '#call' do
        let(:temp_file_path) { '/tmp/foobar' }
        let(:temp_file_pointer) { OpenStruct.new(path: temp_file_path) }
        let(:file_injection) { 'MockFileInjection' }
        let(:file_injection_creator) { 'MockFileInjectionCreator' }
        let(:session) { 'MockSession' }
        let(:username) { 'foouser' }
        let(:key_injection_options) {{
          target_username: username,
          file_injection_creator: file_injection_creator
        }}
        let(:key_injection) { PublicSshKeyInjection.new(session, key_injection_options) }
        let(:expected_file_injection_options) {[
          session,
          {
            :source_path => temp_file_path,
            :target_path => "~#{username}/.ssh/authorized_keys",
            :owner => username,
            :group => username
          }
        ]}

        before do
          temp_file_pointer.expects(:unlink)
          Tempfile.expects(:new).yields(temp_file_pointer).returns(temp_file_pointer)
          write_file('data/public_keys/foobar.pubkey', 'foobar')
          temp_file_pointer.expects(:puts).with('foobar')
        end

        it 'injects the file' do
          file_injection_creator.expects(:new).with(*expected_file_injection_options).returns(file_injection)
          file_injection.expects(:call)

          key_injection.call
        end
      end
    end
  end
end
