# frozen_string_literal: true

class API::Reports::UncheckedController < API::BaseController
  before_action :require_staff_login_for_api
  def index
    @reports = Report.unchecked.not_wip.list.page(params[:page])
  end

  def counts
    @reports = Report
               .unchecked
               .not_wip
  end
end
