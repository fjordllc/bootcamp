# frozen_string_literal: true

class RequestRetirementsController < ApplicationController
  skip_before_action :require_active_user_login, raise: false, only: %i[new show create]
  before_action :set_request_retirement, only: %i[show]

  def new
    if logged_in? && current_user.belongs_company_and_adviser?
      @request_retirement = RequestRetirement.new(requester_profile)
      @target_users = current_user.collegues_other_than_self
    else
      @request_retirement = RequestRetirement.new
    end
  end

  def show; end

  def create
    @request_retirement = RequestRetirement.new(request_retirement_params)
    if @request_retirement.save
      UserMailer.request_retirement(@request_retirement).deliver_now
      redirect_to request_retirement_url(@request_retirement)
    else
      @target_users = current_user.collegues_other_than_self if logged_in? && current_user.belongs_company_and_adviser?
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_request_retirement
    @request_retirement = RequestRetirement.find(params[:id])
  end

  def request_retirement_params
    params.require(:request_retirement)
          .permit(:requester_email,
                  :requester_name,
                  :company_name,
                  :target_user_name,
                  :reason,
                  :keep_data)
  end

  def requester_profile
    {
      requester_email: current_user.email,
      requester_name: current_user.login_name,
      company_name: current_user.company.name
    }
  end

  def temporarily_store_session(key, info)
    session[key] = info
  end
end
