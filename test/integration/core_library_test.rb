require 'test_helper'
require 'fileutils'

module Minionizer
  class MinionTestFailure < StandardError; end
  class CoreLibraryTest < MiniTest::Unit::TestCase
    roll_back_to_blank_snapshot if minion_available?

    describe 'core library' do
      let(:fqdn) { '192.168.49.181' }
      let(:username) { 'vagrant' }
      let(:password) { 'vagrant' }
      let(:credentials) {{ 'username' => username, 'password' => password }}
      let(:session) { Session.new(fqdn, credentials) }
      let(:minionization) { Minionization.new([fqdn], Configuration.instance) }
      let(:minions) {{ fqdn => { 'ssh' => credentials, 'roles' => ['test_role'] } }}

      before do
        skip unless minion_available?
        Configuration.instance.instance_variable_set(:@minions, nil)
        write_file('config/minions.yml', minions.to_yaml)
        create_role(code)
      end

      describe FolderCreation do
        let(:filename) { "foo/dir" }
        let(:ownername) { 'otheruser' }
        let(:path) { "/home/vagrant/#{filename}" }
        let(:options) {{ path: path, mode: '0700', owner: ownername, group: ownername }}
        let(:code) { %Q{Minionizer::FolderCreation.new( session, #{options}).call} }

        before do
          refute_directory_exists(path)
        end

        it 'creates a folder' do
          session.exec("sudo adduser --disabled-password --gecos '#{ownername}'  #{ownername}")
          assert_throws(:high_five) { minionization.call }
          assert_directory_exists(path)
          mode = session.exec("stat --format=%a #{path}")[:stdout]
          assert_equal('700',mode)
          owner = session.exec("stat --format=%U #{path}")[:stdout]
          assert_equal(ownername, owner)
          group = session.exec("stat --format=%G #{path}")[:stdout]
          assert_equal(ownername, group)
        end
      end

      describe FileInjection do
        let(:filename) { 'foobar.txt' }
        let(:source_path) { "/some/source/#{filename}" }
        let(:target_path) { "/home/vagrant/#{filename}" }
        let(:options) {{ source_path: source_path, target_path: target_path }}
        let(:code) { %Q{Minionizer::FileInjection.new( session, #{options}).call} }

        before do
          refute_file_exists(target_path)
          write_file(source_path, 'FooBar')
        end

        it 'injects a file' do
          assert_throws(:high_five) { minionization.call }
          assert_file_exists(target_path)
        end
      end

      #######
      private
      #######

      def create_role(injected_code)
        role_code = without_fakefs do
          ERB.new(File.open('test/role_template.rb.erb').read.strip).result(binding)
        end
        write_file('roles/test_role.rb', role_code)
      end

      def assert_file_exists(path)
        assert(link_exists?(path, :f), "#{path} file expected to exist")
      end

      def refute_file_exists(path)
        refute(link_exists?(path, :f), "#{path} file NOT expected to exist")
      end

      def assert_directory_exists(path)
        assert(link_exists?(path, :d), "#{path} directory expected to exist")
      end

      def refute_directory_exists(path)
        refute(link_exists?(path, :d), "#{path} directory NOT expected to exist")
      end

      def link_exists?(path, parameter = :e)
        session.exec("[ -#{parameter} #{path} ] && echo 'yes'")[:stdout] == 'yes'
      end

    end
  end
end
