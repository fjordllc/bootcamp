# frozen_string_literal: true

class Users::ReportsController < ApplicationController
  before_action :require_login
  before_action :set_user
  before_action :set_reports

  def index
  end

  private
    def set_user
      @user = User.find(params[:user_id])
    end

    def set_reports
      @reports = user.reports
        .eager_load(:user, :comments)
        .paging_with_created_at(page: params[:page], order_type: "desc")
    end

    def user
      @user ||= User.find(params[:user_id])
    end
end
