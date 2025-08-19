# frozen_string_literal: true

class Reports::UncheckedController < ApplicationController
  PAGER_NUMBER = 25

  before_action :require_staff_login
  def index
    @reports = Report.unchecked.not_wip.list.page(params[:page]).per(PAGER_NUMBER)
    @unchecked = @reports.exists?
  end
end
