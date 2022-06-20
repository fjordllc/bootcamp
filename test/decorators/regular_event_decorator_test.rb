# frozen_string_literal: true

require 'test_helper'

class RegularEventDecoratorTest < ActiveSupport::TestCase
  include ActionView::TestCase::Behavior

  def setup
    ActiveDecorator::ViewContext.push(controller.view_context)
    @regular_event = ActiveDecorator::Decorator.instance.decorate(regular_events(:regular_event1))
  end

  test 'holding_cycles' do
    assert_equal '毎週日曜日', @regular_event.holding_cycles
  end

  test 'next_event_date' do
    assert_equal "次回の開催日は #{l @regular_event.filtered_canditates_of_next_event_date.compact.min} です" , @regular_event.next_event_date
  end
end
