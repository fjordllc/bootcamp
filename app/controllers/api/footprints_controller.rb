# frozen_string_literal: true

class API::FootprintsController < API::BaseController
  def index
    footprintable_data = footprintable
    if params[:footprintable_type].present? && footprintable_data.present?
      footprintable_data.footprints.create_or_find_by(user: current_user) if footprintable_data.user != current_user
      @footprints = footprintable_data.footprints.with_avatar.order(created_at: :desc)
      @footprint_total_count = @footprints.size
    else
      head :bad_request
    end
  end

  private

  def footprintable
    params[:footprintable_type].constantize.find_by(id: params[:footprintable_id])
  end
end
