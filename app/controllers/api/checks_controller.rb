# frozen_string_literal: true

class API::ChecksController < API::BaseController
  before_action :require_staff_login_for_api, only: %i[create destroy]

  def index
    @checks = Check.where(
      checkable: checkable
    )
  end

  def create
    if checkable.checks.empty?
      @check = Check.new(
        user: current_user,
        checkable: checkable
      )

      @check.save!
      render json: {}, status: :created
    else
      render json: { message: "この日報は確認済です。" }, status: :unprocessable_entity
    end
  end

  def destroy
    @check = Check.find(params[:id]).destroy
    render json: {}, status: :ok
  end

  private

  def checkable
    params[:checkable_type].constantize.find_by(id: params[:checkable_id])
  end
end
