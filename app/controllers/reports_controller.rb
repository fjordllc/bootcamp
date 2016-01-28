class ReportsController < ApplicationController
  before_action :require_login
  before_action :set_reports, only: %w(show edit update destroy sort)
  before_action :set_report, only: %w(show edit update destroy sort)
  before_action :set_user, only: :show
  respond_to :html, :json

  def index
  end

  def show
  end

  def new
    @report = Report.new
    @report_flag = true
    @report_date = Time.zone.today
    @user_name = current_user.login_name
  end

  def edit
    @report.user = current_user
  end

  def create
    @report = Report.new(report_params)
    @report.user = current_user
    if @report.save
      redirect_to @report,
      notice: t("report_was_successfully_created")
    else
      render :new
    end
  end

  def update
    if @report.update(report_params)
      redirect_to @report,
      notice: t("report_was_successfully_updated")
    else
      render :edit
    end
  end

  def destroy
    @report.destroy
    notify "<#{url_for(current_user)}|#{current_user.login_name}>が
            <#{url_for(@report)}|#{@report.title}>を削除しました。"
    redirect_to reports_url, notice: t("report_was_successfully_deleted")
  end

  private

  def report_params
    params.require(:report).permit(
      :title,
      :description
    )
  end

  def set_reports
    @reports = Report.order(updated_at: :desc)
  end

  def set_report
    @report = Report.find(params[:id])
  end

  def set_user
    @user = User.find_by(id: params[:user_id])
  end
end
