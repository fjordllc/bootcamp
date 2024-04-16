# frozen_string_literal: true

require 'test_helper'

class UpcomingEventsGroupTest < ActiveSupport::TestCase
  setup do
    original_events = [Event.today_events, RegularEvent.today_events].flatten
    @date = :today
    @upcoming_events = original_events.map { |e| UpcomingEvent.wrap(e) }
  end

  test '#build' do
    assert_equal UpcomingEventsGroup.new(@date, @upcoming_events), UpcomingEventsGroup.build(@date)
  end
end
