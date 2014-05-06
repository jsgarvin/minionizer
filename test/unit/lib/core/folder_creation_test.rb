require 'test_helper'

module Minionizer
  class FolderCreationTest < MiniTest::Unit::TestCase
    describe FolderCreation do
      let(:session) { 'MockSession' }
      let(:path) { '/foo/bar' }
      let(:folder_creation) { FolderCreation.new(session, options) }

      describe '#call' do

        describe 'only path is provided' do
          let(:options) {{ path: path }}

          it 'sends the mkdir command' do
            session.expects(:exec).with(%Q{mkdir --parents #{path}})
            folder_creation.call
          end

        end

        describe 'mode is provided' do
          let(:mode) { '0700' }
          let(:options) {{ path: path, mode: mode }}

          it 'sets the folder permissions' do
            session.expects(:exec).with(%Q{mkdir --parents #{path}})
            session.expects(:exec).with(%Q{chmod #{mode} #{path}})
            folder_creation.call
          end
        end

        describe 'owner is provided' do
          let(:ownername) { 'otherowner' }
          let(:options) {{ path: path, owner: ownername }}

          it 'sets the folder owner' do
            session.expects(:exec).with(%Q{mkdir --parents #{path}})
            session.expects(:exec).with(%Q{chown #{ownername} #{path}})
            folder_creation.call
          end
        end

        describe 'group is provided' do
          let(:groupname) { 'othergroup' }
          let(:options) {{ path: path, group: groupname }}

          it 'sets the folder group' do
            session.expects(:exec).with(%Q{mkdir --parents #{path}})
            session.expects(:exec).with(%Q{chgrp #{groupname} #{path}})
            folder_creation.call
          end
        end

      end
    end
  end
end
