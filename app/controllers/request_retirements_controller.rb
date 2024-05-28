# frozen_string_literal: true

class RequestRetirementsController < ApplicationController
  before_action :set_request_retirement, only: %i[show]

  def new
    @request_retirement = RequestRetirement.new
    @target_users = current_user.collegues_other_than_self
  end

  def show; end

  def create
    @request_retirement = RequestRetirement.new(request_retirement_params)
    @request_retirement.user = current_user
    @request_retirement.target_user = User.find(request_retirement_params[:target_user_id])
    if @request_retirement.save
      #UserMailer.request_retirement(@request_retirement).deliver_now
      redirect_to request_retirement_url(@request_retirement)
    else
      @target_users = current_user.collegues_other_than_self
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
end
