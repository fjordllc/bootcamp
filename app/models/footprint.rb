# frozen_string_literal: true

class Footprint < ApplicationRecord
  belongs_to :user, touch: true
  belongs_to :footprintable, polymorphic: true
  validates :user_id, presence: true
end
