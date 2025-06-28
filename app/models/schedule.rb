# frozen_string_literal: true

class Schedule < ApplicationRecord
  belongs_to :pair_work
  validates :proposed_at, presence: true
end
