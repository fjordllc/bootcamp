# frozen_string_literal: true

class Organizer < ApplicationRecord
  belongs_to :user
  belongs_to :regular_event

  validates :user_id, uniqueness: { scope: :regular_event_id }

  def delete_and_assign_new
    event = regular_event
    before_organizer_ids = event.organizer_ids

    delete
    event.assign_admin_as_organizer_if_none

    ActiveSupport::Notifications.instrument('organizer.create', regular_event: event, before_organizer_ids:, sender: user)
  end
end
