# frozen_string_literal: true

class FootprintsController < ApplicationController
  def self.footprint_create_or_find(footprintable_type, footprintable_id, user)
    footprintable = footprintable_type.constantize.find_by(id: footprintable_id)

    if footprintable.present?
      footprintable.footprints.create_or_find_by(user:) if footprintable.user != user
      footprintable.footprints.with_avatar.order(created_at: :desc)
    else
      []
    end
  end
end
