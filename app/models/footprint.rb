# frozen_string_literal: true

class Footprint < ApplicationRecord
  belongs_to :user
  belongs_to :footprintable, polymorphic: true
  validates :user_id, presence: true
end
