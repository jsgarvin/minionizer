require 'test_helper'

module Minionizer
  class RoleTemplateTest < MiniTest::Unit::TestCase

    describe RoleTemplate do
      let(:session) { 'MockSession' }
      let(:template) { RoleTemplate.new(session) }

      it 'initilizes' do
        assert_kind_of(RoleTemplate, template)
      end

      describe '#call' do
        it 'raises' do
          assert_raises(StandardError) { template.call }
        end
      end
    end

  end
end

