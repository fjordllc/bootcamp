# frozen_string_literal: true

require 'test_helper'

class UpcomingEventsGroupTest < ActiveSupport::TestCase
  setup do
    @today_events_group = UpcomingEventsGroup.build(:today)
    @tomorrow_events_group = UpcomingEventsGroup.build(:tomorrow)
  end

  test '#date' do
    assert_equal :today, @today_events_group.date
    assert_equal :tomorrow, @tomorrow_events_group.date
  end
end
