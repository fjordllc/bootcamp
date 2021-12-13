# frozen_string_literal: true

class API::Users::RecentReportsController < API::BaseController
  def index
    @user = User.find(params[:user_id])
    @reports = @user.reports.limit(10).order(reported_on: :DESC)
  end
end
