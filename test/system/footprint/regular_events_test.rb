# frozen_string_literal: true

require 'application_system_test_case'

class Footprint::RegularEventsTest < ApplicationSystemTestCase
  setup do
    @regular_event = regular_events(:regular_event2)
  end

  test 'click on the link to view the rest of footprints' do
    user_data = User.unhibernated.unretired.last(11)
    user_data.map do |user|
      Footprint.create(
        user_id: user.id,
        footprintable_id: @regular_event.id,
        footprintable_type: 'RegularEvent'
      )
    end

    visit_with_auth regular_event_path(@regular_event), 'komagata'

    find('.user-icons__more').click
    assert_no_css '.user-icons__more'
  end
end
