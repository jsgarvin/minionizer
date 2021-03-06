require 'test_helper'
require 'fileutils'

module Minionizer
  class MinionTestFailure < StandardError; end
  class CoreLibraryTest < MiniTest::Test
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

      describe UserCreation do
        let(:new_name) { 'Test User' }
        let(:new_username) { 'testuser' }
        let(:options) {{ name: new_name, username: new_username }}
        let(:code) { %Q{
          session.sudo do
            Minionizer::UserCreation.new( session, #{options}).call
          end
        } }

        before do
          refute_user_exists(new_username)
        end

        it 'creates a user' do
          2.times { assert_throws(:high_five) { minionization.call } }
          assert_user_exists(new_username)
        end
      end

      describe FolderCreation do
        let(:filename) { "foo/dir" }
        let(:ownername) { 'otheruser' }
        let(:path) { "/home/vagrant/#{filename}" }
        let(:options) {{ path: path, mode: '0700', owner: ownername, group: ownername }}
        let(:code) { %Q{
          session.sudo do
            Minionizer::FolderCreation.new( session, #{options}).call
          end
        } }

        before do
          refute_directory_exists(path)
          session.sudo("adduser --disabled-password --gecos '#{ownername}'  #{ownername}")
        end

        after do
          skip unless minion_available?
          session.sudo("userdel #{ownername}")
        end

        it 'creates a folder' do
          2.times { assert_throws(:high_five) { minionization.call } }
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
        let(:ownername) { 'otheruser' }
        let(:options) {{
          source_path: source_path,
          target_path: target_path,
          mode: '0700',
          owner: ownername,
          group: ownername
        }}
        let(:code) { %Q{
          session.sudo do |sudo_session|
            Minionizer::FileInjection.new(sudo_session, #{options}).call
          end
        } }

        before do
          refute_file_exists(target_path)
          write_file(source_path, 'FooBar')
          session.sudo("adduser --disabled-password --gecos '#{ownername}'  #{ownername}")
        end

        after do
          skip unless minion_available?
          session.sudo("userdel #{ownername}")
        end

        it 'injects a file' do
          2.times { assert_throws(:high_five) { minionization.call } }
          assert_file_exists(target_path)
          assert_equal('FooBar', session.sudo("cat #{target_path}")[:stdout])
          mode = session.exec("stat --format=%a #{target_path}")[:stdout]
          assert_equal('700',mode)
          owner = session.exec("stat --format=%U #{target_path}")[:stdout]
          assert_equal(ownername, owner)
          group = session.exec("stat --format=%G #{target_path}")[:stdout]
          assert_equal(ownername, group)
        end
      end

      describe PublicSshKeyInjection do
        let(:source_path) { "data/public_keys" }
        let(:target_username) { 'otheruser' }
        let(:options) {{ target_username: target_username }}
        let(:code) { %Q{
          session.sudo do |sudo_session|
            Minionizer::PublicSshKeyInjection.new(sudo_session, #{options}).call
          end
        } }

        before do
          Dir.mkdir('/tmp')
          refute_file_exists("~#{target_username}/.ssh/authorized_keys")
          write_file("#{source_path}/foobar.pubkey", 'FooBar')
          write_file("#{source_path}/foobaz.pubkey", 'FooBaz')
          session.exec("sudo adduser --disabled-password --gecos '#{target_username}'  #{target_username}")
        end

        after do
          File.delete("#{source_path}/foobar.pubkey")
          File.delete("#{source_path}/foobaz.pubkey")
          skip unless minion_available?
          session.sudo("userdel #{target_username}")
        end

        it 'injects public keys' do
          2.times { assert_throws(:high_five) { minionization.call } }
          assert_file_exists("/home/#{target_username}/.ssh/authorized_keys")
          assert_match(/FooBar/, session.sudo("cat ~#{target_username}/.ssh/authorized_keys")[:stdout])
          assert_match(/FooBaz/, session.sudo("cat ~#{target_username}/.ssh/authorized_keys")[:stdout])
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
        session.sudo("[ -#{parameter} #{path} ] && echo 'yes' || echo 'no'")[:stdout] == 'yes'
      end

      def assert_user_exists(username)
        assert(user_exists?(username), "User '#{username}' expected to exist")
      end

      def refute_user_exists(username)
        refute(user_exists?(username), "User '#{username}' expected to NOT exist")
      end

      def user_exists?(username)
        session.exec("id #{username} || echo 'no'")[:stdout] != 'no'
      end

    end
  end
end
