# frozen_string_literal: true

class API::Reports::RecentsController < API::BaseController
  def index
    @reports = Report
               .includes(:checks, user: [{ avatar_attachment: :blob }, :company])
               .not_wip
               .order(reported_on: :desc, id: :desc)
               .limit(20)
  end
end
