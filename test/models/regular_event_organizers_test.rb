# frozen_string_literal: true

require 'test_helper'

class RegularEventOrganizerTest < ActiveSupport::TestCase
  test '#delete_and_assign_new' do
    organizer = regular_event_organizers(:organizer12)
    event = organizer.regular_event

    assert_changes -> { RegularEventOrganizer.where(regular_event: event, user: organizer.user).exists? }, from: true, to: false do
      organizer.delete_and_assign_new
    end

    assert RegularEventOrganizer.where(regular_event: event).exists?
  end
end
