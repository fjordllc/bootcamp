# frozen_string_literal: true

require 'test_helper'

class RegularEventDecoratorTest < ActiveSupport::TestCase
  include ActionView::TestCase::Behavior

  def setup
    ActiveDecorator::ViewContext.push(controller.view_context)
    @regular_event = ActiveDecorator::Decorator.instance.decorate(regular_events(:regular_event1))
    @finished_regular_event = ActiveDecorator::Decorator.instance.decorate(regular_events(:regular_event8))
    @regular_event_repeat_rule = ActiveDecorator::Decorator.instance.decorate(regular_event_repeat_rules(:regular_event_repeat_rule1))
  end

  test 'holding_cycles' do
    assert_equal '毎週日曜日', @regular_event.holding_cycles
  end

  test 'next_holding_date' do
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

  test 'event_day?' do
    travel_to Time.zone.local(2022, 6, 5, 0, 0, 0) do
      assert_equal true, @regular_event.event_day?
    end

    travel_to Time.zone.local(2022, 6, 1, 0, 0, 0) do
      assert_equal false, @regular_event.event_day?
    end
  end

  test 'convert_date_into_week' do
    assert_equal 1, @regular_event.convert_date_into_week(1)
    assert_equal 2, @regular_event.convert_date_into_week(8)
    assert_equal 3, @regular_event.convert_date_into_week(15)
    assert_equal 4, @regular_event.convert_date_into_week(22)
  end

  test 'next_event_date' do
    travel_to Time.zone.local(2022, 6, 1, 0, 0, 0) do
      assert_equal Date.new(2022, 6, 5), @regular_event.next_event_date
    end
  end

  test 'possible_next_event_date' do
    travel_to Time.zone.local(2022, 6, 1, 0, 0, 0) do
      first_day = Time.zone.today
      assert_equal Date.new(2022, 6, 5), @regular_event.possible_next_event_date(first_day, @regular_event_repeat_rule)
    end
  end

  test 'next_specific_day_of_the_week' do
    travel_to Time.zone.local(2022, 6, 1, 0, 0, 0) do
      assert_equal Date.new(2022, 6, 5), @regular_event.next_specific_day_of_the_week(@regular_event_repeat_rule)
    end
  end
end
