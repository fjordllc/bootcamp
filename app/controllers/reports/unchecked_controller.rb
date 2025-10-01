# frozen_string_literal: true

class Reports::UncheckedController < ApplicationController
  PAGER_NUMBER = 25
  before_action :require_admin_or_mentor!

  def index
    @reports = Report.list.page(params[:page]).per(PAGER_NUMBER)
    @reports = @reports.unchecked.not_wip
    render 'reports/index'
  end

  private

  def require_admin_or_mentor!
    redirect_to reports_path unless admin_or_mentor_login?
  end
end
