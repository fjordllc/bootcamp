# frozen_string_literal: true

require 'test_helper'

class RegularEventTest < ActiveSupport::TestCase
  test '#organizers' do
    regular_event = regular_events(:regular_event1)
    organizers = users(:komagata)
    assert_includes regular_event.organizers, organizers
  end

  test 'is invalid when start_at >= end_at' do
    regular_event = regular_events(:regular_event1)
    regular_event.end_at = regular_event.start_at - 1.hour
    assert regular_event.invalid?
  end

  test '#event_day?' do
    regular_event = regular_events(:regular_event1)
    travel_to Time.zone.local(2022, 6, 5, 0, 0, 0) do
      assert_equal true, regular_event.event_day?
    end

    travel_to Time.zone.local(2022, 6, 1, 0, 0, 0) do
      assert_equal false, regular_event.event_day?
    end
  end

  test '#convert_date_into_week' do
    regular_event = regular_events(:regular_event1)
    assert_equal 1, regular_event.convert_date_into_week(1)
    assert_equal 2, regular_event.convert_date_into_week(8)
    assert_equal 3, regular_event.convert_date_into_week(15)
    assert_equal 4, regular_event.convert_date_into_week(22)
  end

  test '#next_event_date' do
    regular_event = regular_events(:regular_event1)
    travel_to Time.zone.local(2022, 6, 1, 0, 0, 0) do
      assert_equal Date.new(2022, 6, 5), regular_event.next_event_date
    end
  end

  test '#possible_next_event_date' do
    regular_event = regular_events(:regular_event1)
    regular_event_repeat_rule = regular_event_repeat_rules(:regular_event_repeat_rule1)
    travel_to Time.zone.local(2022, 6, 1, 0, 0, 0) do
      first_day = Time.zone.today
      assert_equal Date.new(2022, 6, 5), regular_event.possible_next_event_date(first_day, regular_event_repeat_rule)
    end
  end

  test '#next_specific_day_of_the_week' do
    regular_event = regular_events(:regular_event1)
    regular_event_repeat_rule = regular_event_repeat_rules(:regular_event_repeat_rule1)
    travel_to Time.zone.local(2022, 6, 1, 0, 0, 0) do
      assert_equal Date.new(2022, 6, 5), regular_event.next_specific_day_of_the_week(regular_event_repeat_rule)
    end
  end

  test '#cancel_participation' do
    regular_event = regular_events(:regular_event1)
    participant = regular_event_participations(:regular_event_participation1).user

    regular_event.cancel_participation(participant)
    assert_not regular_event.regular_event_participations.find_by(user_id: participant.id)
  end
end
