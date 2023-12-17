# frozen_string_literal: true

require 'test_helper'

class OrganizerTest < ActiveSupport::TestCase
  test '#delete_and_assign_new' do
    organizer = organizers(:organizer12)
    event = organizer.regular_event

    assert_changes -> { Organizer.where(regular_event: event, user: organizer.user).exists? }, from: true, to: false do
      organizer.delete_and_assign_new
    end

    assert Organizer.where(regular_event: event).exists?
  end
end
