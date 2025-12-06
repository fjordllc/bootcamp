# frozen_string_literal: true

class API::InquiriesController < API::Admin::BaseController
  def update
    inquiry = Inquiry.find(params[:id])
    action_completed = params[:inquiry][:action_completed]
    if action_completed
      if inquiry.action_completed?
        head :unprocessable_entity
      else
        inquiry.update!(action_completed:, completed_by_user: current_user, completed_at: Time.zone.now)
        head :no_content
      end
    else
      inquiry.update!(action_completed:, completed_by_user: nil, completed_at: nil)
      head :no_content
    end
  end
end
