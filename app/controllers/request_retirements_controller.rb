# frozen_string_literal: true

class RequestRetirementsController < ApplicationController
  before_action :set_request_retirement, only: %i[show]
  before_action :deny_not_requester, only: %i[show]

  def new
    @request_retirement = RequestRetirement.new
  end

  def show; end

  def create
    @request_retirement = RequestRetirement.new(request_retirement_params)
    @request_retirement.user = current_user
    @request_retirement.target_user = User.find(request_retirement_params[:target_user_id])

    if @request_retirement.save
      UserMailer.request_retirement(@request_retirement).deliver_now
      redirect_to request_retirement_path(@request_retirement)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_request_retirement
    @request_retirement = RequestRetirement.find(params[:id])
  end

  def request_retirement_params
    params.require(:request_retirement)
          .permit(:target_user_id,
                  :reason,
                  :keep_data)
  end

  def deny_not_requester
    return if @request_retirement.user == current_user

    redirect_to root_path, alert: '退会申請をしたユーザーのみが閲覧可能です'
  end
end
