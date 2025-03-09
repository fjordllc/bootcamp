# frozen_string_literal: true

class Footprint < ApplicationRecord
  include WithAvatar

  belongs_to :user
  belongs_to :footprintable, polymorphic: true
  validates :user_id, presence: true

  def self.create_on_resource(resource, current_user)
    find_or_create_by(footprintable: resource, user: current_user)
  end

  def self.fetch_for_resource(resource)
    where(footprintable: resource)
      .includes(:user)
      .where.not(user_id: resource.user.id)
      .order(created_at: :desc)
  end

  def self.count_for_resource(resource)
    fetch_for_resource(resource).count
  end
end
