# frozen_string_literal: true

require 'test_helper'

class EventOrganizerWatcherTest < ActiveSupport::TestCase
  test '#call' do
    event = events(:event3)
    payload = { event: }
    assert_difference 'Watch.where(user: event.user, watchable: event).count', 1 do
      EventOrganizerWatcher.new.call('event.create', Time.current, Time.current, 'unique_id', payload)
    end
  end
end
