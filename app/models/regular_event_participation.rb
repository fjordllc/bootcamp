# frozen_string_literal: true

class RegularEventParticipation < ApplicationRecord
  belongs_to :user
  belongs_to :regular_event

  validates :user_id, uniqueness: { scope: :regular_event_id }

  scope :holding, lambda {
    joins(:regular_event).merge(RegularEvent.holding)
  }
end
