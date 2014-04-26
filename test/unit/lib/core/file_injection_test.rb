require 'test_helper'

module Minionizer
  class FileInjectionTest < MiniTest::Unit::TestCase

    describe FileInjection do
      let(:session) { 'MockSession' }
      let(:source_path) { 'data/source_file.txt'}
      let(:target_path) { '/var/target_file.txt'}
      let(:options) {{ source_path: source_path, target_path: target_path }}
      let(:injection) { FileInjection.new(session, options) }

      it 'instantiates' do
        assert_kind_of(FileInjection, injection)
      end

      describe '#call' do
        let(:source_contents) { 'Source Contents' }

        before do
          write_file(source_path, source_contents)
        end

        it 'sends a command to session' do
          session.expects(:exec).with(%Q{echo '#{source_contents}' > #{target_path}})
          injection.call
        end
      end

    end
  end
end


