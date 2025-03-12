# frozen_string_literal: true

class ReportsController < ApplicationController
  PAGER_NUMBER = 25

  include Rails.application.routes.url_helpers
  before_action :set_report, only: %i[show]
  before_action :set_my_report, only: %i[destroy]
  before_action :set_editable_report, only: %i[edit update]
  before_action :set_checks, only: %i[show]
  before_action :set_check, only: %i[show]
  before_action :set_user, only: %i[show]
  before_action :set_categories, only: %i[create update]
  before_action :set_watch, only: %i[show]

  def index
    @reports = Report.list.page(params[:page]).per(PAGER_NUMBER)
    @reports = @reports.joins(:practices).where(practices: { id: params[:practice_id] }) if params[:practice_id].present?
  end

  def show
    @products = @report.user.products.not_wip.order(published_at: :desc)
    @recent_reports = Report.list.where(user_id: @report.user.id).limit(10)
    Footprint.find_or_create_by(footprintable: @report, user: current_user) unless @report.user == current_user
    @footprints = Footprint.fetch_for_resource(@report)
    respond_to do |format|
      format.html
      format.md
    end
  end

  def new
    year, month, day = params[:reported_on].scan(/\d+/).map(&:to_i) if params[:reported_on]
    @report = if Date.valid_date?(year, month, day)
                Report.new(reported_on: params[:reported_on].to_date)
              else
                Report.new(reported_on: Date.current)
              end
    @report.learning_times.build

    return unless params[:id]

    report              = current_user.reports.find(params[:id])
    @report.title       = report.title
    @report.emotion = report.emotion
    @report.description = "<!-- #{report.reported_on} の日報をコピー -->\n" + report.description
    @report.practices   = report.practices
    flash.now[:notice] = '日報をコピーしました。'
  end

  def edit
    @report.no_learn = true if @report.learning_times.empty?
  end

  def create
    @report = Report.new(report_params)
    @report.user = current_user
    set_wip
    canonicalize_learning_times(@report)
    if @report.save
      Newspaper.publish(:report_save, { report: @report })
      redirect_to redirect_url(@report), notice: notice_message(@report), flash: flash_contents(@report)
    else
      render :new
    end
  end

  def update
    before_wip_status = @report.wip
    set_wip
    @report.practice_ids = nil if params[:report][:practice_ids].nil?
    @report.assign_attributes(report_params)
    canonicalize_learning_times(@report)
    if @report.save
      Newspaper.publish(:report_save, { report: @report })
      redirect_to redirect_url(@report), notice: notice_message(@report), flash: flash_contents(@report)
    else
      @report.wip = before_wip_status
      render :edit
    end
  end

  def destroy
    @report.destroy
    Newspaper.publish(:report_destroy, { report: @report })
    redirect_to reports_url, notice: '日報を削除しました。'
  end

  private

  def report_params
    params.require(:report).permit(
      :title,
      :reported_on,
      :emotion,
      :no_learn,
      :description,
      practice_ids: [],
      learning_times_attributes: %i[id started_at finished_at _destroy]
    )
  end

  def set_report
    @report = Report.find(params[:id])
  end

  def set_my_report
    @report = current_user.reports.find(params[:id])
  end

  def set_editable_report
    @report = current_user.mentor? ? Report.find(params[:id]) : current_user.reports.find(params[:id])
  end

  def set_user
    @user = User.find_by(id: params[:user_id])
  end

  def set_check
    @check = Check.new
  end

  def report
    @report ||= Report.find(params[:id])
  end

  def set_checks
    @checks = report.checks.order(created_at: :desc)
  end

  def set_categories
    @categories = Category.eager_load(:practices).where.not(practices: { id: nil }).order('categories_practices.position')
  end

  def set_wip
    @report.wip = params[:commit] == 'WIP'
  end

  def redirect_url(report)
    report.wip? ? edit_report_url(report) : report_url(report)
  end

  def notice_message(report)
    report.wip? ? '日報をWIPとして保存しました。' : '日報を保存しました。'
  end

  def flash_contents(report)
    { notify_help: !report.wip? && report.sad?,
      celebrate_report_count: celebrating_count(report) }
  end

  CELEBRATING_COUNTS = [100, 200, 222, 300, 333, 400, 500, 555, 600, 700, 777, 800, 900, 1000, 1024, 1100, 1111, 1200, 1234, 1300, 1400, 1500].freeze

  def celebrating_count(report)
    return nil if report.wip

    report_count = current_user.reports.not_wip.count
    CELEBRATING_COUNTS.find { |count| count == report_count }
  end

  def set_watch
    @watch = Watch.new
  end

  def canonicalize_learning_times(report)
    report.learning_times.each do |learning_time|
      new_started_at = learning_time.started_at.change(
        year: report.reported_on.year,
        month: report.reported_on.month,
        day: report.reported_on.day
      )
      new_finished_at = learning_time.finished_at.change(
        year: report.reported_on.year,
        month: report.reported_on.month,
        day: report.reported_on.day
      )
      new_finished_at += 1.day if new_started_at > new_finished_at
      learning_time.assign_attributes(started_at: new_started_at, finished_at: new_finished_at)
    end
  end
end
