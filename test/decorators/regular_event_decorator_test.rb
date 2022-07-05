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

  test 'repeat_rules' do
    assert_equal [{ frequency: 0, day_of_the_week: 0 }], @regular_event.repeat_rules
  end

  test 'canditates_next_event_date' do
    travel_to Time.zone.local(2022, 6, 1, 0, 0, 0) do
      assert_equal [Date.new(2022, 6, 5)], @regular_event.canditates_next_event_date
    end
  end

  test 'canditate_next_event_date' do
    repeat_rule = { frequency: 0, day_of_the_week: 0 }
    travel_to Time.zone.local(2022, 6, 1, 0, 0, 0) do
      first_day = Time.zone.today
      assert_equal Date.new(2022, 6, 5), @regular_event.canditate_next_event_date(first_day, repeat_rule)
    end
  end

  test 'next_specific_day_of_the_week' do
    repeat_rule = { frequency: 0, day_of_the_week: 0 }
    travel_to Time.zone.local(2022, 6, 1, 0, 0, 0) do
      assert_equal Date.new(2022, 6, 5), @regular_event.next_specific_day_of_the_week(repeat_rule)
    end
  end
end
