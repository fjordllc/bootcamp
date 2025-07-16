# frozen_string_literal: true

class API::ChecksController < API::BaseController
  before_action :require_staff_login_for_api, only: %i[create destroy]

  def index
    @checks = Check.where(
      checkable:
    )
  end

  def create
    if checkable.checks.empty?
      @check = Check.create!(
        user: current_user,
        checkable:
      )
      ActiveSupport::Notifications.instrument('check.create', check: @check)
      head :created
    else
      render json: { message: "この#{checkable.class.model_name.human}は確認済です。" }, status: :unprocessable_entity
    end
  end

  def destroy
    @check = Check.find(params[:id]).destroy
    ActiveSupport::Notifications.instrument('check.cancel', check: @check)

    head :no_content
  end

  private

  def checkable
    params[:checkable_type].constantize.find_by(id: params[:checkable_id])
  end
end
