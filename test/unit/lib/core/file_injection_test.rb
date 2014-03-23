require 'test_helper'

module Minionizer
  class FileInjectionTest < MiniTest::Unit::TestCase

    describe FileInjection do
      let(:session) { 'MockSession' }
      let(:injection) { FileInjection.new(session) }

      it 'instantiates' do
        assert_kind_of(FileInjection, injection)
      end

      describe '#call' do
        let(:source_contents) { 'Source Contents' }
        let(:source) { 'data/source_file.txt'}
        let(:target) { '/var/target_file.txt'}

        before do
          write_file(source, source_contents)
          session.expects(:exec).with(%Q{echo '#{source_contents}' > #{target}})
        end

        it 'sends a command to session' do
          injection.inject(source, target)
        end
      end

    end
  end
end


