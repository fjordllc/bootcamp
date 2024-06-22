# frozen_string_literal: true

class Users::MicroReportsController < ApplicationController
  before_action :set_user

  def index
    @micro_reports = @user.micro_reports.order(created_at: :desc)
  end

  def create
    @micro_report = @user.micro_reports.build(micro_report_params)

    if @micro_report.save
      flash[:notice] = '分報を投稿しました。'
    else
      flash[:alert] = '分報の投稿に失敗しました。'
    end
    redirect_to user_micro_reports_path(@user)
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def micro_report_params
    params.require(:micro_report).permit(:content)
  end
end
