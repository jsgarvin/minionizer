require 'test_helper'

module Minionizer
  class FolderCreationTest < MiniTest::Unit::TestCase
    describe FolderCreation do
      let(:session) { 'MockSession' }
      let(:path) { '/foo/bar' }
      let(:mode) { '0700' }
      let(:options) {{ path: path, mode: mode }}
      let(:folder_creation) { FolderCreation.new(session, options) }

      describe '#call' do

        it 'sends the command to session' do
          session.expects(:exec).with(%Q{mkdir --parents #{path}})
          session.expects(:exec).with(%Q{chmod #{mode} #{path}})
          folder_creation.call
        end

      end
    end
  end
end
