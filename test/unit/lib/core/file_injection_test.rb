require 'test_helper'

module Minionizer
  class FileInjectionTest < MiniTest::Test

    describe FileInjection do
      let(:session) { 'MockSession' }
      let(:source_path) { 'data/source_file.txt'}
      let(:target_path) { '/var/target_file.txt'}
      let(:injection) { FileInjection.new(session, options) }

      describe '#call' do
        let(:source_contents) { 'Source Contents' }

        before do
          write_file(source_path, source_contents)
          session.expects(:exec).with(%Q{mkdir --parents #{File.dirname(target_path)}})
          session.expects(:exec).with(%Q{echo '#{source_contents}' > #{target_path}})
        end

        describe 'only source and target are provided' do
          let(:options) {{ source_path: source_path, target_path: target_path }}

          it 'sends a command to session' do
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


