require 'test_helper'

module Minionizer
  class FolderCreationTest < MiniTest::Unit::TestCase
    describe FolderCreation do
      let(:session) { 'MockSession' }
      let(:path) { '/foo/bar' }
      let(:options) {{ path: path }}
      let(:folder_creation) { FolderCreation.new(session, options) }

      describe '#call' do

        it 'sends the command to session' do
          session.expects(:exec).with(%Q{mkdir --parents --verbose '#{path}'})
          folder_creation.call
        end

      end
    end
  end
end
