class ReportsController < ApplicationController
  include Rails.application.routes.url_helpers
  include Gravatarify::Helper
  before_action :require_login
  before_action :set_search_word, only: :index
  before_action :set_reports, only: %w(index show edit update destroy)
  before_action :set_report, only: %w(show)
  before_action :set_my_report, only: %i(edit update destroy)
  before_action :set_comments, only: %w(show edit update destroy)
  before_action :set_comment, only: %w(show edit update destroy)
  before_action :set_user, only: :show
  before_action :update_read_flag, only: :show

  def index
  end

  def show
  end

  def new
    @report = Report.new
    if params[:format].present?
      @report_copy_flag = true
      @report = Report.find_by(id: params[:format])
      @report_title = @report.title
      @report_description = @report.description
      @report = Report.new
    else
      @report_flag = true
      @report_date = Time.current
      @user_name = current_user.login_name
    end
  end

  def edit
    @report.user = current_user
  end

  def create
    @report = Report.new(report_params)
    @report.user = current_user
    if @report.save
      notify_to_slack(@report)
      redirect_to @report, notice: t('report_was_successfully_created')
    else
      render :new
    end
  end

  def update
    if @report.update(report_params)
      redirect_to @report, notice: t('report_was_successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    @report.destroy
    redirect_to reports_url, notice: t('report_was_successfully_deleted')
  end

  private

  def report_params
    params.require(:report).permit(
      :title,
      :description,
      :practice_ids => []
    )
  end

  def set_search_word
    @search_word = params[:word]
  end

  def set_reports
    if params[:word].present?
      @reports = Report.where('title LIKE ? or description LIKE ?', "%#{@search_word}%", "%#{@search_word}%").order(updated_at: :desc, id: :desc).page(params[:page]).per(15)
    elsif params[:practice_id].present?
      @reports = Practice.find(params[:practice_id]).reports.page(params[:page]).per(15)
    else
      @reports = Report.order(updated_at: :desc, id: :desc).page(params[:page]).per(30)
    end
  end

  def set_report
    @report = Report.find(params[:id])
  end

  def set_my_report
    @report = current_user.reports.find(params[:id])
  end

  def set_user
    @user = User.find_by(id: params[:user_id])
  end

  def set_comment
    @comment = Comment.new
  end

  def set_comments
    @comments = Comment.where(report_id: @report.id).order(created_at: :asc)
  end

  def notify_to_slack(report)
    name = "#{report.user.login_name}"
    link = "<#{report_url(report)}|#{report.title}>"

    notify "#{name} created #{link}",
      username: "#{report.user.login_name} (#{report.user.full_name})",
      icon_url: gravatar_url(report.user),
      attachments: [{
        fallback: "report body.",
        text: report.description
      }]
  end

  def update_read_flag
    activities = PublicActivity::Activity.where(recipient_id: current_user.id, read_flag: 0)
    activities.each do |activity|
      if params[:id].to_i == activity.parameters[:report]
        activity.read_flag = 1
        activity.save!
      end
    end
  end
end
