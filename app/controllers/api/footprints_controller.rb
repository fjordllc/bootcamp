# frozen_string_literal: true

class API::FootprintsController < API::BaseController
  def index
    if params[:footprintable_type].present?
      footprintable.footprints.create_or_find_by(user: current_user) if footprintable.user != current_user
      @footprints = footprintable.footprints.with_avatar.order(created_at: :desc)
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
