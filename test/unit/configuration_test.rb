require 'test_helper'

module Minionizer
  class ConfigurationTest < MiniTest::Unit::TestCase

    describe Configuration do
      let(:config) { Configuration.instance }

      it 'instantiates a configuration' do
        assert_kind_of(Configuration, config)
      end

      describe 'minions' do
        let(:minions) { { 'foo.bar.com' => 1 } }

        before do
          write_file('config/minions.yml', minions.to_yaml
        end

        it 'loads the minions' do
          assert_kind_of(Hash, config.minions)
          assert_includes(config.minions.keys, 'foo.bar.com')
        end
      end

    end
  end
end
