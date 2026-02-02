# frozen_string_literal: true

class Organizer < ApplicationRecord
  belongs_to :user
  belongs_to :regular_event

  validates :user_id, uniqueness: { scope: :regular_event_id }

  scope :not_finished, lambda {
    joins(:regular_event).merge(RegularEvent.not_finished)
  }
end
