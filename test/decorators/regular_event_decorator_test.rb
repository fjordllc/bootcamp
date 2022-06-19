# frozen_string_literal: true

require 'test_helper'

class RegularEventDecoratorTest < ActiveSupport::TestCase
  def setup
    @regular_event = ActiveDecorator::Decorator.instance.decorate(regular_events(:regular_event1))
  end

  test 'holding_cycles' do
    assert_equal '毎週日曜日', @regular_event.holding_cycles
  end
end
