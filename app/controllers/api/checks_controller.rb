# frozen_string_literal: true

class API::ChecksController < API::BaseController
  before_action :require_staff_login_for_api, only: %i[create destroy]

  def index
    @checks = Check.where(
      checkable: checkable
    )
  end

  def create
    @check = Check.new(
      user: current_user,
      checkable: checkable
    )

    @check.save!
    head :created
  end

  def destroy
    @check = Check.find(params[:id]).destroy
    head :no_content
  end

  private

  def checkable
    params[:checkable_type].constantize.find_by(id: params[:checkable_id])
  end
end
