# frozen_string_literal: true

class API::Users::CurrentUserReportsController < API::BaseController
  def index
    @reports = Report.where(user_id: current_user.id).order(reported_on: :desc)
  end
end
