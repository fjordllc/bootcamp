# frozen_string_literal: true

class API::Reports::UncheckedController < API::BaseController
  before_action :require_staff_login
  def index
    @reports = Report.unchecked.not_wip.list.page(params[:page])
  end
end
