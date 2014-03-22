require 'test_helper'

module Minionizer
  class VictoryLap < StandardError; end
  class MinionTestFailure < StandardError; end
  class BasicConnectionTest < MiniTest::Unit::TestCase

    describe 'making a basic connection' do
      let(:fqdn) { '192.168.49.181' }
      let (:username) { 'vagrant' }
      let (:password) { 'vagrant' }
      let(:credentials) {{ 'username' => username, 'password' => password }}
      let(:session) { Session.new(fqdn, credentials) }

      before do
        skip unless minion_available?
      end

      it 'successfully retrieves the hostname from a remote system' do
        assert_equal('precise32', session.exec(:hostname))
      end

      describe 'full integration' do
        let(:minionization) { Minionization.new([fqdn], Configuration.instance) }
        let(:minions) {{ fqdn => { 'ssh' => credentials, 'roles' => ['minion_test'] } }}
        let(:test_role) { <<-endstr
                           class MinionTest
                             attr_reader :session

                             def initialize(session)
                               @session = session
                             end

                             def call
                               if hostname == 'precise32'
                                 raise Minionizer::VictoryLap.new('Shazam!')
                               else
                                 raise Minionizer::MinionTestFailure.new("Whawhawhaaaa... \#{hostname}")
                               end
                             end

                             def hostname
                               @hostname ||= session.exec(:hostname)
                             end
                           end
                          endstr
        }

        before do
          Configuration.instance.instance_variable_set(:@minions, nil)
          write_file('config/minions.yml', minions.to_yaml)
          write_file('roles/minion_test.rb', test_role)
        end

        it 'exercises from start to finish' do
          assert_raises(VictoryLap) do
            minionization.call
          end
        end
      end
    end

  end
end
