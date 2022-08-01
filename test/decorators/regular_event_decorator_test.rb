# frozen_string_literal: true

require 'test_helper'

class RegularEventDecoratorTest < ActiveSupport::TestCase
  include ActionView::TestCase::Behavior

  def setup
    ActiveDecorator::ViewContext.push(controller.view_context)
    @regular_event = ActiveDecorator::Decorator.instance.decorate(regular_events(:regular_event1))
    @finished_regular_event = ActiveDecorator::Decorator.instance.decorate(regular_events(:regular_event8))
  end

  test '#holding_cycles' do
    assert_equal '毎週日曜日', @regular_event.holding_cycles
  end

  test '#next_holding_date' do
    travel_to Time.zone.local(2022, 6, 1, 0, 0, 0) do
      assert_equal '次回の開催日は 2022年06月05日 です', @regular_event.next_holding_date
    end

    travel_to Time.zone.local(2022, 6, 5, 0, 0, 0) do
      assert_equal '本日開催', @regular_event.next_holding_date
    end

    travel_to Time.zone.local(2022, 6, 5, 15, 30, 0) do
      assert_equal '次回の開催日は 2022年06月12日 です', @regular_event.next_holding_date
    end

    travel_to Time.zone.local(2022, 6, 1, 0, 0, 0) do
      assert_equal '開催終了', @finished_regular_event.next_holding_date
    end
  end
end
