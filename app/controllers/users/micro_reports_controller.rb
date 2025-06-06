# frozen_string_literal: true

class Users::MicroReportsController < ApplicationController
  PAGER_NUMBER = 25
  FIRST_PAGE = 1

  before_action :set_user
  before_action :set_micro_report, only: %i[destroy]

  def index
    @micro_reports = @user.micro_reports.order(created_at: :asc).page(params[:page]).per(PAGER_NUMBER)
  end

  def create
    @micro_report = @user.micro_reports.build(micro_report_params)

    if current_user == @user && @micro_report.save
      flash[:notice] = '分報を投稿しました。'
    else
      flash[:alert] = '分報の投稿に失敗しました。'
    end

    redirect_to user_micro_reports_path(@user, page: @user.latest_micro_report_page)
  end

  def destroy
    @micro_report.destroy!

    referer_path = request.referer
    if page_out_of_range?(referer_path)
      redirect_to user_micro_reports_path(@user, page: @user.latest_micro_report_page)
    else
      redirect_to referer_path
    end
    flash[:notice] = '分報を削除しました。'
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_micro_report
    @micro_report = current_user.admin? ? MicroReport.find(params[:id]) : current_user.micro_reports.find(params[:id])
  end

  def micro_report_params
    params.require(:micro_report).permit(:content)
  end

  def page_out_of_range?(referer_path)
    matched_page_number = referer_path.match(/page=(\d+)/)
    page_number = matched_page_number ? matched_page_number[1] : FIRST_PAGE

    MicroReport.page(page_number).out_of_range?
  end
end
