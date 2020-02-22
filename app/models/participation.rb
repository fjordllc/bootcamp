# frozen_string_literal: true

class Participation < ApplicationRecord
  belongs_to :user
  belongs_to :event

  scope :disabled, -> { where(enable: false) }

  after_create ParticipationCallbacks.new
  after_destroy ParticipationCallbacks.new
end
