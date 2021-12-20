# frozen_string_literal: true

class API::Users::CurrentUserReportsController < API::BaseController
  def index
    @reports = current_user.reports.order(reported_on: :desc)
  end
end
