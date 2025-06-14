# frozen_string_literal: true

class API::InquiriesController < API::BaseController
  def update
    inquiry = Inquiry.lock.find(params[:id])
    Inquiry.transaction do
      if inquiry.update(inquiry_params)
        if inquiry.action_completed
          Check.find_or_create_by!(user: current_user, checkable: inquiry)
        else
          inquiry.checks.destroy_all
        end
        head :ok
      else
        head :unprocessable_entity
      end
    end
  end

  private

  def inquiry_params
    params.require(:inquiry).permit(:action_completed)
  end
end
