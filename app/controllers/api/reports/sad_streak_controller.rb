# frozen_string_literal: true

class API::Reports::SadStreakController < API::BaseController
  def index
    ids = User.where(
      hibernated_at: nil,
      retired_on: nil,
      graduated_on: nil,
      sad_streak: true
    ).pluck(:last_sad_report_id)
    @reports = Report.joins(:user).where(id: ids).order(reported_on: :desc)
  end
end
