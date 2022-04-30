# frozen_string_literal: true

require 'test_helper'

class EventOrganizerWatcherTest < ActiveSupport::TestCase
  test '#call' do
    event = events(:event1)
    assert_difference 'Watch.where(user: event.user, watchable: event).count', 1 do
      EventOrganizerWatcher.new.call(event)
    end
  end
end
