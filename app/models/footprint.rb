# frozen_string_literal: true

class Footprint < ApplicationRecord
  include WithAvatar

  belongs_to :user
  belongs_to :footprintable, polymorphic: true
  validates :user_id, presence: true

  def self.find_footprints(resource, current_user)
    find_or_create_by(footprintable: resource, user: current_user) if resource.user != current_user
    where(footprintable: resource)
      .includes(:user)
      .where.not(user_id: resource.user.id)
      .order(created_at: :desc)
  end
end
