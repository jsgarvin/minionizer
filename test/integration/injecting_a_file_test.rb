require 'test_helper'

module Minionizer
  class InjectingAFileTest < MiniTest::Unit::TestCase

    describe 'injecting a file' do
      let(:fqdn) { '192.168.49.181' }
      let (:username) { 'vagrant' }
      let (:password) { 'vagrant' }
      let(:credentials) {{ 'username' => username, 'password' => password }}
      let(:session) { Session.new(fqdn, credentials) }

      let(:injection) { FileInjection.new(session) }
      let(:filename) { 'foobar.txt' }
      let(:target) { "/vagrant/#{filename}" }

      before do
        write_file(filename, 'FooBar')
      end

      it 'puts the file on the server' do
        begin
          injection.inject(filename, target)

          FakeFS.deactivate!
          assert(File.exists?(File.expand_path("../../#{filename}", __FILE__)))
        ensure
          File.delete(File.expand_path("../../#{filename}", __FILE__))
          FakeFS.activate!
        end
      end
    end
  end
end
