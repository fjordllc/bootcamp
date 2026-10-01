# frozen_string_literal: true

class API::Reports::LatestController < API::BaseController
  def show
    report = current_user
             .reports
             .order(reported_on: :desc)
             .first
    return render_not_found('最新の日報が見つかりません。') unless report

    render json: { id: report.id, title: report.title, practice_ids: report.practice_ids, description: report.description }
  end
end
