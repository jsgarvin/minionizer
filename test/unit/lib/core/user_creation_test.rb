require 'test_helper'

module Minionizer
  class UserCreationTest < MiniTest::Test
    describe UserCreation do
      let(:session) { 'MockSession' }
      let(:full_name) { 'Test User' }
      let(:username) { 'testuser' }
      let(:options) {{ name: full_name, username: username }}
      let(:user_creation) { UserCreation.new(session, options) }

      describe '#call' do

        describe 'user does not already exist' do

          before do
            session.stubs(:exec).with(%Q{id #{username}}).raises(CommandExecution::CommandError.new)
          end

          it 'creates the user' do
            session.expects(:exec).with(%Q{adduser --disabled-password --gecos '#{full_name}' #{username}})
            user_creation.call
          end

        end

        describe 'user already exists' do

          before do
            session.stubs(:exec).with(%Q{id #{username}}).returns(true)
          end

          it 'does not create the user' do
            session.expects(:exec).with(%Q{adduser --disabled-password --gecos '#{full_name}' #{username}}).never
            user_creation.call
          end

        end
      end

    end
  end
end

