# frozen_string_literal: true

class Footprint < ApplicationRecord
  belongs_to :user
  belongs_to :report
  validates :user_id, presence: true
  validates :report_id, presence: true
end
