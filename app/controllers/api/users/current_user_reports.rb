# frozen_string_literal: true

class API::ReportsController < API::BaseController
  def index
    @reports = Report.where(user_id: current_user.id)
  end
end
