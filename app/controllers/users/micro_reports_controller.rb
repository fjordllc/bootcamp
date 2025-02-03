# frozen_string_literal: true

class Users::MicroReportsController < ApplicationController
  PAGER_NUMBER = 25

  before_action :set_user

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

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def micro_report_params
    params.require(:micro_report).permit(:content)
  end
end
