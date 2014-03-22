require 'test_helper'

module Minionizer
  class ConfigurationTest < MiniTest::Unit::TestCase

    describe Configuration do
      let(:config) { Configuration.instance }
      let(:minions) {{ 'foo.bar.com' => { :ssh => { :username => 'foo', :password => 'bar' } } }}

      before do
        write_file('config/minions.yml', minions.to_yaml)
      end

      it 'instantiates a configuration' do
        assert_kind_of(Configuration, config)
      end

      describe 'minions' do

        it 'loads the minions' do
          assert_kind_of(Hash, config.minions)
          assert_includes(config.minions.keys, 'foo.bar.com')
        end
      end

    end
  end
end
