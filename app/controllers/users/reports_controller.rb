# frozen_string_literal: true

class Users::ReportsController < MemberAreaController
  before_action :set_user
  before_action :set_reports

  def index
  end

  private
    def set_user
      @user = User.find(params[:user_id])
    end

    def set_reports
      @reports = user.reports.eager_load(:user, :comments).default_order.page(params[:page])
    end

    def user
      @user ||= User.find(params[:user_id])
    end
end
