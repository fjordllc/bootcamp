# frozen_string_literal: true

class Api::Reports::UncheckedController < Api::BaseController
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
