# frozen_string_literal: true

class Hibernation < ApplicationRecord
  belongs_to :user
  validates :reason, presence: true
  validates :scheduled_return_on, presence: true
end
