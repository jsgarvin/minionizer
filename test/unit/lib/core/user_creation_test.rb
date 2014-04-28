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

        it 'creates the user' do
          session.expects(:exec).with(%Q{sudo adduser --disabled-password --gecos '#{name}' #{username}})
          user_creation.call
        end

      end

    end
  end
end

