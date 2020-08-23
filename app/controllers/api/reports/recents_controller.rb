# frozen_string_literal: true

class API::Reports::RecentsController < API::BaseController
  def index
    @reports = Report
      .includes({ user: { avatar_attachment: :blob } })
      .not_wip
      .order(reported_on: :desc, id: :desc)
      .limit(10)
  end
end
