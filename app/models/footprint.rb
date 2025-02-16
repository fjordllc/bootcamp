# frozen_string_literal: true

class Footprint < ApplicationRecord
  include WithAvatar

  belongs_to :user
  belongs_to :footprintable, polymorphic: true
  validates :user_id, presence: true

  def self.record_footprint(resource, current_user)
    find_or_create_by(footprintable: resource, user: current_user)
  end

  def self.fetch_footprints(resource)
    where(footprintable: resource)
      .includes(:user)
      .where.not(user_id: resource.user.id)
      .order(created_at: :desc)
  end

  def self.footprint_count(resource)
    fetch_footprints(resource).count
  end
end
