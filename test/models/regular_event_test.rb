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

  test '#holding_today?' do
    regular_event = regular_events(:regular_event1)
    travel_to Time.zone.local(2022, 6, 5, 0, 0, 0) do
      assert regular_event.holding_today?
    end

    travel_to Time.zone.local(2022, 6, 1, 0, 0, 0) do
      assert_not regular_event.holding_today?
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

  test '#holding_tomorrow?' do
    regular_event = regular_events(:regular_event1)
    travel_to Time.zone.local(2023, 2, 25, 0, 0, 0) do
      assert regular_event.holding_tomorrow?
    end

    travel_to Time.zone.local(2023, 2, 26, 0, 0, 0) do
      assert_not regular_event.holding_tomorrow?
    end
  end

  test '#holding_day_after_tomorrow?' do
    regular_event = regular_events(:regular_event1)
    travel_to Time.zone.local(2022, 12, 30, 0, 0, 0) do
      assert regular_event.holding_day_after_tomorrow?
    end

    travel_to Time.zone.local(2022, 1, 1, 0, 0, 0) do
      assert_not regular_event.holding_day_after_tomorrow?
    end
  end

  test '#cancel_participation' do
    regular_event = regular_events(:regular_event1)
    participant = regular_event_participations(:regular_event_participation1).user

    regular_event.cancel_participation(participant)
    assert_not regular_event.regular_event_participations.find_by(user_id: participant.id)
  end

  test '#watched_by?' do
    regular_event = regular_events(:regular_event1)
    user = users(:kimura)
    assert_not regular_event.watched_by?(user)

    watch = Watch.new(user: user, watchable: regular_event)
    watch.save
    assert regular_event.watched_by?(user)
  end

  test '#participated_by?' do
    regular_event = regular_events(:regular_event1)
    user = users(:hatsuno)
    assert regular_event.participated_by?(user)

    user = users(:komagata)
    assert_not regular_event.participated_by?(user)
  end

  test '.comming_soon_events' do
    regular_event = regular_events(:regular_event26)
    user = users(:kimura)

    travel_to Time.zone.local(2023, 4, 10, 0, 0, 0) do
      today_regular_events, tomorrow_regular_events = RegularEvent.comming_soon_events(user)
      assert today_regular_events.size == 1 && today_regular_events.include?(regular_event)
      assert tomorrow_regular_events.size == 1 && tomorrow_regular_events.include?(regular_event)
    end
  end

  test '.remove_event' do
    regular_event1 = regular_events(:regular_event1)
    regular_event2 = regular_events(:regular_event2)
    regular_event3 = regular_events(:regular_event3)
    regular_events1 = [regular_event1, regular_event2]
    regular_events2 = [regular_event3]

    RegularEvent.remove_event([regular_events1, regular_events2], regular_event1.id)
    assert_not regular_events1.include?(regular_event1)
    assert regular_events1.include?(regular_event2)
    assert regular_events2.include?(regular_event3)
  end

  test '#not_held?' do
    weekdays = Time.zone.parse('2023-8-10')
    holidays = Time.zone.parse('2023-8-11')

    regular_event_not_held_on_holidays = regular_events(:regular_event1)
    assert_not regular_event_not_held_on_holidays.not_held?(weekdays)
    assert regular_event_not_held_on_holidays.not_held?(holidays)

    regular_event_held_on_holidays = regular_events(:regular_event4)
    assert_not regular_event_held_on_holidays.not_held?(weekdays)
    assert_not regular_event_held_on_holidays.not_held?(holidays)
  end
end
