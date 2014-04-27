require 'test_helper'
require 'fileutils'

module Minionizer
  class MinionTestFailure < StandardError; end
  class AcceptanceTest < MiniTest::Unit::TestCase
    roll_back_to_blank_snapshot if minion_available?

    describe 'acceptance testing' do
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
        let(:path) { "/home/vagrant/#{filename}" }
        let(:code) { <<-eos
          Minionizer::FolderCreation.new( session,
            path: '#{path}',
            mode: '0700',
          ).call
          eos
        }

        before do
          refute_directory_exists(path)
        end

        it 'creates a folder' do
          assert_throws(:high_five) { minionization.call }
          assert_directory_exists(path)
          mode = session.exec("stat --format=%a #{path}")
          assert_equal(mode,'700')
        end
      end

      describe FileInjection do
        let(:filename) { 'foobar.txt' }
        let(:source_path) { "/some/source/#{filename}" }
        let(:target_path) { "/home/vagrant/#{filename}" }
        let(:code) { <<-eos
          Minionizer::FileInjection.new( session,
            source_path: '#{source_path}',
            target_path: '#{target_path}',
          ).call
          eos
        }

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
        session.exec("[ -#{parameter} #{path} ] && echo 'yes'") == 'yes'
      end

    end
  end
end
