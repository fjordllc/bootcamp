# frozen_string_literal: true

require 'application_system_test_case'

class Footprint::EventsTest < ApplicationSystemTestCase
  setup do
    @event = events(:event1)
  end

  test 'click on the link to view the rest of footprints' do
    user_data = User.unhibernated.unretired.last(11)
    user_data.map do |user|
      Footprint.create(
        user_id: user.id,
        footprintable_id: @event.id,
        footprintable_type: 'Event'
      )
    end

    visit_with_auth event_path(@event), 'komagata'

    find('.user-icons__more').click
    assert_no_css '.user-icons__more'
  end
end
