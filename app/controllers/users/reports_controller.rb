# frozen_string_literal: true

class Users::ReportsController < ApplicationController
  before_action :set_user
  before_action :set_target
  before_action :set_reports
  before_action :set_report
  before_action :set_export
  before_action :require_staff_login

  def index
    respond_to do |format|
      format.html
      format.md do
        if allow_download_reports_only_admin
          send_reports_markdown(@reports_for_export)
        else
          redirect_to root_path, alert: '自分以外の日報はダウンロードすることができません'
        end
      end
    end
  end

  private

  def allow_download_reports_only_admin
    current_user.admin? || @report.user_id == current_user.id
  end

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_reports
    case @target
    when 'unchecked_reports'
      @reports = Report.unchecked.not_wip
    else
      @reports = user.reports.not_wip
    end
  end

  def set_report
    @report = @reports[0]
  end

  def set_target
    @target = params[:target] || 'all_reports'
  end

  def user
    @user ||= User.find(params[:user_id])
  end

  def set_export
    @reports_for_export = @user.reports.not_wip
  end

  def send_reports_markdown(reports)
    Dir.mktmpdir do |folder_path|
      ReportExporter.export(reports, folder_path)
      send_data(File.read("#{folder_path}/reports.zip"), filename: '日報一覧.zip')
    end
  end
end
