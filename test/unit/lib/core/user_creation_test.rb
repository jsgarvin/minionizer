require 'test_helper'

module Minionizer
  class UserCreationTest < MiniTest::Unit::TestCase
    describe UserCreation do
      let(:session) { 'MockSession' }
      let(:name) { 'Test User' }
      let(:username) { 'testuser' }
      let(:options) {{ name: name, username: username }}
      let(:user_creation) { UserCreation.new(session, options) }

      describe '#call' do
        let(:name) { 'Test User' }
        let(:username) { 'testuser' }

        describe 'user does not already exist' do

          before do
            session.stubs(:exec).with(%Q{id #{username}}).raises(CommandExecution::CommandError.new)
          end

          it 'creates the user' do
            session.expects(:exec).with(%Q{adduser --disabled-password --gecos '#{name}' #{username}})
            user_creation.call
          end

        end

        describe 'user already exists' do

          before do
            session.stubs(:exec).with(%Q{id #{username}}).returns(true)
          end

          it 'does not create the user' do
            session.expects(:exec).with(%Q{adduser --disabled-password --gecos '#{name}' #{username}}).never
            user_creation.call
          end

        end
      end

    end
  end
end

