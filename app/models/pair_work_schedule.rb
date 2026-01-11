# frozen_string_literal: true

class PairWorkSchedule < ApplicationRecord
  belongs_to :pair_work
  validates :proposed_at, presence: true
  validates :proposed_at, uniqueness: { scope: :pair_work_id }
end
