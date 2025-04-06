# frozen_string_literal: true

class API::InquiriesController < API::BaseController
  def index
    @inquiries = Inquiry.order(created_at: :desc)
    render json: @inquiries
  end

  def update
    inquiry = Inquiry.find(params[:id])
    if inquiry.update(inquiry_params)
      if inquiry.action_completed && inquiry.checks.empty?
        Check.create!(
          user: current_user,
          checkable: inquiry
        )
      elsif !inquiry.action_completed
        inquiry.checks.destroy_all
      end
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private

  def inquiry_params
    params.require(:inquiry).permit(:action_completed)
  end
end
