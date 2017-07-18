class ChecksController < ApplicationController
  include Rails.application.routes.url_helpers
  include Gravatarify::Helper

  def create
    @report = Report.find(params[:report_id])
    @check = Check.new
    @check.user = current_user
    @check.report = @report
    if @check.save
      redirect_to @report, notice: t('report_was_successfully_check')
    else
      render 'reports/report'
    end
  end

  private

  def set_report
    @report = Report.find(params[:report_id])
  end


end
