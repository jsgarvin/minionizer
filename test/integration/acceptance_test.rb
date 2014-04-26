require 'test_helper'
require 'fileutils'

module Minionizer
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
              refute(File.exists?(synced_path_to_created_folder))
              refute(File.exists?(synced_path_to_injected_file))
            end
            assert_throws(:high_five) do
              minionization.call
            end
            without_fakefs do
              assert(
                File.directory?(synced_path_to_created_folder),
                "Failed to find created folder: #{synced_path_to_created_folder}"
              )
              assert(File.exists?(synced_path_to_injected_file))
            end
          ensure
            without_fakefs do
              begin
                FileUtils.rm_rf(synced_path_to_created_folder)
              rescue
                warn "Failed to delete: #{synced_path_to_created_folder}"
              end
              begin
                File.delete(synced_path_to_injected_file)
              rescue
                warn "Failed to delete: #{synced_path_to_injected_file}"
              end
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

      def synced_path_to_created_folder
        @synced_path_to_created_folder ||= File.expand_path("../../#{CREATE_FOLDER_NAME}", __FILE__)
      end

      def synced_path_to_injected_file
        @synced_path_to_injected_file ||= File.expand_path("../../#{INJECTION_SOURCE}", __FILE__)
      end
    end
  end
end

CREATE_FOLDER_NAME = 'foo/dir'
CREATE_FOLDER_PATH = "/vagrant/#{CREATE_FOLDER_NAME}"
INJECTION_SOURCE = 'foobar.txt'
INJECTION_TARGET = "/vagrant/#{INJECTION_SOURCE}"
TEST_ROLE = <<-endofstring
  class MinionTest < Minionizer::RoleTemplate

    def call
      if hostname == 'precise32'
        Minionizer::FolderCreation.new(
          session,
          path: '#{CREATE_FOLDER_PATH}'
        ).call
        Minionizer::FileInjection.new(
          session,
          source_path: '#{INJECTION_SOURCE}',
          target_path: '#{INJECTION_TARGET}'
        ).call
        throw :high_five
      else
        raise Minionizer::MinionTestFailure.new("Whawhawhaaaa... \#{hostname}")
      end
    end

    def hostname
      @hostname ||= session.exec(:hostname)
    end
  end
endofstring
