require 'test_helper'

module Minionizer
  class TaskTemplateTest < MiniTest::Test
    describe TaskTemplate do
      let(:session) { 'MockSession' }
      let(:template) { TaskTemplate.new(session, :foo => 'bar') }

      describe '#method_missing' do

        it 'catches messages that match options' do
          assert_equal('bar', template.foo)
        end

        it 'forwards unrecognized messages to super' do
          assert_raises(NoMethodError) do
            template.foobar
          end
        end

      end

      describe '#respond_to?' do

        it 'recognizes passed in options as respondable methods' do
          assert(template.respond_to?(:foo))
        end

        it 'properly responds to unrecognized methods' do
          refute(template.respond_to?(:foobar))
        end
      end
    end
  end
end
