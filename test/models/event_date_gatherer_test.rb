# frozen_string_literal: true

require 'test_helper'

class EventDateGathererTest < ActiveSupport::TestCase
  test '.all_scheduled_dates(event)' do
    travel_to Time.zone.local(2024, 1, 1) do
      every_sunday_event = regular_events(:regular_event1)
      all_scheduled_dates = EventDateGatherer.all_scheduled_dates(every_sunday_event)

      sunday_counts = 52
      assert_equal sunday_counts, all_scheduled_dates.count
    end

    travel_to Time.zone.local(2024, 1, 1) do
      second_monday_event = regular_events(:regular_event3)
      all_scheduled_dates = EventDateGatherer.all_scheduled_dates(second_monday_event)

      expect_counts = 12
      assert_equal expect_counts, all_scheduled_dates.count
    end
  end
end
