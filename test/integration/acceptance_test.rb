require 'test_helper'

module Minionizer
  class VictoryLap < StandardError; end
  class MinionTestFailure < StandardError; end
  class AcceptanceTest < MiniTest::Unit::TestCase

    describe 'acceptance testing' do
      let(:fqdn) { '192.168.49.181' }
      let (:username) { 'vagrant' }
      let (:password) { 'vagrant' }
      let(:credentials) {{ 'username' => username, 'password' => password }}
      let(:session) { Session.new(fqdn, credentials) }
      let(:minionization) { Minionization.new([fqdn], Configuration.instance) }
      let(:minions) {{ fqdn => { 'ssh' => credentials, 'roles' => ['minion_test'] } }}

      before do
        skip unless minion_available?
        roll_back_to_blank_snapshot
        Configuration.instance.instance_variable_set(:@minions, nil)
        write_file('config/minions.yml', minions.to_yaml)
        write_file('roles/minion_test.rb', TEST_ROLE)
        write_file(INJECTION_SOURCE, 'FooBar')
      end

      describe 'setting up a server' do
        it 'exercises from start to finish' do
          begin
            without_fakefs do
              refute(File.exists?(synced_path_to_injected_file))
            end
            assert_raises(VictoryLap) do
              minionization.call
            end
            without_fakefs do
              assert(File.exists?(synced_path_to_injected_file))
            end
          ensure
            without_fakefs do
              File.delete(synced_path_to_injected_file)
            end
          end
        end
      end

      #######
      private
      #######

      def without_fakefs
        FakeFS.deactivate!
        yield
      ensure
        FakeFS.activate!
      end

      def synced_path_to_injected_file
        @synced_path_to_injected_file ||= File.expand_path("../../#{INJECTION_SOURCE}", __FILE__)
      end
    end
  end
end

INJECTION_SOURCE = 'foobar.txt'
INJECTION_TARGET = "/vagrant/#{INJECTION_SOURCE}"
TEST_ROLE = <<-endofstring
  class MinionTest < Minionizer::RoleTemplate

    def call
      if hostname == 'precise32'
        Minionizer::FileInjection.new(session).inject('#{INJECTION_SOURCE}','#{INJECTION_TARGET}')
        raise Minionizer::VictoryLap.new('Shazam!')
      else
        raise Minionizer::MinionTestFailure.new("Whawhawhaaaa... \#{hostname}")
      end
    end

    def hostname
      @hostname ||= session.exec(:hostname)
    end
  end
endofstring
