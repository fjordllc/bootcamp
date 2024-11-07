# frozen_string_literal: true

class Footprint < ApplicationRecord
  include WithAvatar

  belongs_to :user
  belongs_to :footprintable, polymorphic: true
  validates :user_id, presence: true

  def self.create_or_find(footprintable_type, footprintable_id, user)
    find_or_create_by(
      footprintable_type:,
      footprintable_id:,
      user:
    )
    where(footprintable_type:, footprintable_id:).order(created_at: :desc)
  end
end
