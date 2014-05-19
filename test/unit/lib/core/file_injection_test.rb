require 'test_helper'

module Minionizer
  class FileInjectionTest < MiniTest::Test

    describe FileInjection do
      let(:session) { 'MockSession' }
      let(:target_path) { '/var/target_file.txt'}
      let(:string_io_creator) { mock('StringIO') }
      let(:injection) { FileInjection.new(session, options.merge(string_io_creator: string_io_creator)) }

      describe '#call' do
        let(:source_contents) { 'Source Contents' }
        let(:string_io) { mock('StringIO') }

        before do
          session.expects(:exec).with(%Q{mkdir --parents #{File.dirname(target_path)}})
          session.expects(:scp).with(string_io, target_path)
        end

        describe 'provides raw contents instead of source file' do
          let(:options) {{ contents: source_contents, target_path: target_path }}

          it 'writes the contents to the file' do
            string_io_creator.expects(:new).with(source_contents).returns(string_io)
            injection.call
          end
        end

        describe 'source file is provided' do

          before do
            write_file(source_path, source_contents)
          end

          describe 'source is plain text file' do
            let(:source_path) { 'data/source_file.txt'}
            let(:options) {{ source_path: source_path, target_path: target_path }}

            before do
              string_io_creator.expects(:new).with(source_contents).returns(string_io)
            end

            it 'sends a command to session' do
              injection.call
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

          describe 'source is erb file' do
            let(:source_path) { 'data/source_file.erb'}
            let(:injectable_contents) { 'Successfully Injected Contents' }
            let(:contents_template) { 'Source Contents with ERB: ERB_HERE' }
            let(:source_contents) { contents_template.gsub('ERB_HERE', '<%= injectable_contents %>') }
            let(:expected_contents) { contents_template.gsub('ERB_HERE', injectable_contents) }
            let(:options) {{ source_path: source_path, target_path: target_path }}

            it 'processes the erb' do
              string_io_creator.expects(:new).with(expected_contents).returns(string_io)
              injection.call
            end
          end

        end


      end

    end
  end
end


