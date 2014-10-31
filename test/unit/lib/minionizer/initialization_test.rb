require 'test_helper'

module Minionizer
  class InitializationTest < MiniTest::Test

    describe Initialization do
      let(:path) { '/some/path' }
      let(:initialization) { Initialization.new(path) }

      describe '.create' do
        it 'initializes and saves' do
          Initialization.any_instance.expects(:save)
          Initialization.create('/some/path')
        end
      end

      describe '#save' do

        before do
          File.stubs(:readlines).with("#{path}/.gitignore").returns(['data/secrets'])
          initialization.stubs(:system)
        end

        describe 'directory structure' do

          before do
            File.stubs(:readlines).with("#{path}/.gitignore").returns([])
          end

          let(:folders) {[
            '', #root folder
            '/config',
            '/data/encrypted_secrets',
            '/data/public_keys',
            '/data/secrets',
            '/lib',
            '/roles'
          ]}

          it 'creates it quietly' do
             folders.each do |folder|
               initialization.expects(:system).with("mkdir -p #{path}#{folder}")
             end
             initialization.save
          end
        end

        describe 'minions.yml' do

          it 'touches the file' do
            initialization.
              expects(:system).
              with("touch #{path}/config/minions.yml")
            initialization.save
          end
        end

        describe 'gitignore' do

          before do
            initialization.
              stubs(:system).
              with("touch #{path}/.gitignore")
          end

          it 'touches the file' do
            initialization.
              expects(:system).
              with("touch #{path}/.gitignore")
            initialization.save
          end

          describe 'secrets line already added to file' do

            it 'does not add it again' do
              #################################################################
              ### Because obj.expects().with().never does not properly fail
              ### when the method is called with the given parameters.
              ### https://github.com/freerange/mocha/issues/82
              ### http://stackoverflow.com/q/17287665/811172
              class NeverError < StandardError; end
              initialization.
                stubs(:system).
                with("echo 'data/secrets' > #{path}/.gitignore").
                raises(NeverError)
              begin
                initialization.save
              rescue NeverError
                assert false
              end
              #################################################################
            end
          end

          describe 'secrets line is not in file' do

            before do
              File.stubs(:readlines).with("#{path}/.gitignore").returns(['foo/bar'])
            end

            it 'adds it to the file' do
              initialization.
                expects(:system).
                with("echo 'data/secrets' > #{path}/.gitignore")
              initialization.save
            end
          end
        end
      end
    end

  end
end
