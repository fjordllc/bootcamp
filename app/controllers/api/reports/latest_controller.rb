# frozen_string_literal: true

class API::Reports::LatestController < API::BaseController
  def show
    @report = current_user
              .reports
              .order(reported_on: :desc)
              .first
  end
end
