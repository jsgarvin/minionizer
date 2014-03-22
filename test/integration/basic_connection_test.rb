require 'test_helper'

module Minionizer
  class BasicConnectionTest < MiniTest::Unit::TestCase

    describe 'making a basic connection' do
      let(:fqdn) { '192.168.49.181' }
      let (:username) { 'vagrant' }
      let (:password) { 'vagrant' }
      let(:credentials) {{ 'username' => username, 'password' => password }}
      let(:session) { Session.new(fqdn, credentials) }

      before do
        initialize_minion
      end

      it 'successfully retrieves the hostname from a remote system' do
        assert_equal('precise32', session.exec('hostname').first)
      end
    end

  end
end
