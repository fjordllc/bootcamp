# frozen_string_literal: true

class API::CurrentUser::ReportsController < API::BaseController
  def index
    @reports = current_user.reports.order(reported_on: :desc).list.page(params[:page])
  end
end
