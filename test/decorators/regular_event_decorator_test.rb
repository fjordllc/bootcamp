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
    travel_to Time.zone.local(2022, 6, 1, 0, 0, 0) do
      assert_equal '次回の開催日は 2022年06月05日 です', @regular_event.next_event_date
    end
  end

  test 'filtered_canditates_of_next_event_date' do
    travel_to Time.zone.local(2022, 6, 1, 0, 0, 0) do
      assert_equal [Date.new(2022, 6, 5)], @regular_event.filtered_canditates_of_next_event_date
    end
  end

  test 'repeat_rules' do
    assert_equal [{ frequency: 0, day_of_the_week: 0 }], @regular_event.repeat_rules
  end

  test 'canditates_of_next_event_date' do
    travel_to Time.zone.local(2022, 6, 1, 0, 0, 0) do
      assert_equal Date.new(2022, 6, 2), @regular_event.canditates_of_next_event_date[0]
      assert_equal Date.new(2022, 7, 6), @regular_event.canditates_of_next_event_date[-1]
    end

    assert_equal 35, @regular_event.canditates_of_next_event_date.size
  end

  test 'canditate_of_next_event_date_with_frequency' do
    repeat_rule = { frequency: 0, day_of_the_week: 0 }
    travel_to Time.zone.local(2022, 6, 1, 0, 0, 0) do
      assert_equal Date.new(2022, 6, 5), @regular_event.canditate_of_next_event_date_with_frequency(repeat_rule)
    end
  end

  test 'calc_week_of_month' do
    assert_equal 1, @regular_event.calc_week_of_month(Date.new(2022, 6, 1))
    assert_equal 2, @regular_event.calc_week_of_month(Date.new(2022, 6, 8))
    assert_equal 3, @regular_event.calc_week_of_month(Date.new(2022, 6, 15))
    assert_equal 4, @regular_event.calc_week_of_month(Date.new(2022, 6, 22))
    assert_equal 5, @regular_event.calc_week_of_month(Date.new(2022, 6, 29))
  end
end
