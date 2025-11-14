# frozen_string_literal: true

class Api::Reports::RecentsController < Api::BaseController
  def index
    @reports = Report
               .includes({ user: { avatar_attachment: :blob } }, :checks)
               .not_wip
               .order(reported_on: :desc, id: :desc)
               .limit(20)
  end
end
