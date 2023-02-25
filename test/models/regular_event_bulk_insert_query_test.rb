# frozen_string_literal: true

require 'test_helper'

class RegularEventBulkInsertQueryTest < ActiveSupport::TestCase
  test '#execute' do
    regular_event = regular_events(:regular_event3)
    target = User.students_and_trainees.ids
    RegularEventBulkInsertQuery.new(regular_event: regular_event, target: target).execute

    assert_equal regular_event.regular_event_participations.count, target.count
  end
end
