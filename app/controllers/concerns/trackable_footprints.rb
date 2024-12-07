# frozen_string_literal: true

module TrackableFootprints
  extend ActiveSupport::Concern

  private

  def find_footprints(resource)
    resource.footprints.find_or_create_by(user: current_user) if resource.user != current_user
    resource.footprints.where.not(user_id: resource.user.id).order(created_at: :desc)
  end
end
