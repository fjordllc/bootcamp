# frozen_string_literal: true

class Organizer < ApplicationRecord
  belongs_to :user
  belongs_to :regular_event

  validates :user_id, uniqueness: { scope: :regular_event_id }

  def delete_and_assign_new
    event = regular_event

    delete
    event.assign_admin_as_organizer_if_none
  end
end
