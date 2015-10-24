class ReportsController < ApplicationController
  before_action :require_login
  before_action :set_report, only: %w(show edit update destroy sort)
  before_action :set_user, only: :show
  before_action :set_user_updated, only: %w(show edit update)
  respond_to :html, :json

  def index
    @reports = Report.order(updated_at: :desc)
    # @reports_edit = Report.order(updated_at: :desc)
    @user = User.find_by(id: params[:user_id])
    # @user_updated = User.find_by(id: params[:user_id_updated])
    # render :edit
  end

  def show
    @reports = Report
    @user = User.find_by(id: params[:user_id])
    # @user_updated = User.find_by(id: params[:user_id_updated])
  end

  def new
    @report = Report.new
    @report_flag = true
    @report_date = Date.today
    @user_name = current_user.login_name
  end

  def edit
    @report.user = current_user
    # @report.user_updated = current_user
  end

  def create
    @report = Report.new(report_params)
    @report.user = current_user
    # @report.user_updated = current_user
    # @report.update_column("user_id_updated = current_user.id")
    if @report.save
      redirect_to @report,
        notice: t('report_was_successfully_created')
    else
      render :new
    end
    # @report = Report.new

    # if @report.save
    #   notify "<#{url_for(current_user)}|#{current_user.login_name}>が<#{url_for(@report)}|#{@report.title}>を作成しました。"
    #   redirect_to @report, notice: t('report_was_successfully_created')
    # else
    #   render :new
    # end
  end

  def update
    # @user_updated = current_user
    # @report.user = current_user
    # @user_updated = current_user
    if @report.update(report_params)
      redirect_to @report,
        notice: t('report_was_successfully_updated')
    else
      render :edit
    end
    # old_report = @report.dup
    # if @report.update(report_params)
    #   text = "<#{url_for(current_user)}|#{current_user.login_name}>が<#{url_for(@report)}|#{@report.title}>を編集しました。"
    #   notify text, pretext: text, title: "差分", value: Diffy::Diff.new(old_report.all_text + "\n", @report.all_text + "\n").to_s
    #   flash[:notice] = t('report_was_successfully_updated')
    # end
    # respond_with @report
  end

  def destroy
    @report.destroy
    notify "<#{url_for(current_user)}|#{current_user.login_name}>が<#{url_for(@report)}|#{@report.title}>を削除しました。"
    redirect_to reports_url, notice: t('report_was_successfully_deleted')
  end

  private

  def report_params
    params.require(:report).permit(
      :title,
      :description
    )
  end

  def set_report
    @report = Report.find(params[:id])
  end

  def set_user
    @user = User.find_by(id: params[:user_id])
    # @user_updated = User.find_by(id: params[:user_id_updated])
  end

  def set_user_updated
    # @user = User.find_by(id: params[:user_id])
    @user_updated = User.find_by(id: params[:user_id_updated])
  end
end
