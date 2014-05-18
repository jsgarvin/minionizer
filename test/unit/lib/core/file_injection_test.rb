require 'test_helper'

module Minionizer
  class FileInjectionTest < MiniTest::Test

    describe FileInjection do
      let(:session) { 'MockSession' }
      let(:source_path) { 'data/source_file.txt'}
      let(:target_path) { '/var/target_file.txt'}
      let(:string_io_creator) { mock('StringIO') }
      let(:injection) { FileInjection.new(session, options.merge(string_io_creator: string_io_creator)) }

      describe '#call' do
        let(:source_contents) { 'Source Contents' }
        let(:string_io) { mock('StringIO') }

        before do
          write_file(source_path, source_contents)
          string_io_creator.expects(:new).with(source_contents).returns(string_io)
          session.expects(:exec).with(%Q{mkdir --parents #{File.dirname(target_path)}})
          session.expects(:scp).with(string_io, target_path)
        end

        describe 'only source and target are provided' do
          let(:options) {{ source_path: source_path, target_path: target_path }}

          it 'sends a command to session' do
            injection.call
          end

        end

        describe 'provides contents instead of source file' do
          let(:options) {{ contents: source_contents, target_path: target_path }}

          it 'writes the contents to the file' do
            injection.call
          end
        end

        describe 'mode is provided' do
          let(:mode) { '0700' }
          let(:options) {{ source_path: source_path, target_path: target_path, mode: mode }}

          it 'sets the file permissions' do
            session.expects(:exec).with(%Q{chmod #{mode} #{target_path}})
            injection.call
          end
        end

        describe 'owner is provided' do
          let(:ownername) { 'otheruser' }
          let(:options) {{ source_path: source_path, target_path: target_path, owner: ownername }}

          it 'sets the file owner' do
            session.expects(:exec).with(%Q{chown #{ownername} #{target_path}})
            injection.call
          end
        end

        describe 'group is provided' do
          let(:groupname) { 'othergroup' }
          let(:options) {{ source_path: source_path, target_path: target_path, group: groupname }}

          it 'sets the file group' do
            session.expects(:exec).with(%Q{chgrp #{groupname} #{target_path}})
            injection.call
          end
        end

      end

    end
  end
end


