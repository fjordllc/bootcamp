# frozen_string_literal: true

class TalksController < ApplicationController
  before_action :require_login, only: %i[show]
  before_action :require_admin_login, only: %i[index]
  before_action :set_talk, only: %i[show update]
  before_action :set_user, only: %i[show update]
  before_action :set_members, only: %i[show]
  before_action :allow_show_talk_page_only_admin, only: %i[show]

  def index
    @target = params[:target]
    @target = 'all' unless API::TalksController::TARGETS.include?(@target)
  end

  def show; end

  def update
    if @user.update(user_params)
      redirect_to talk_url, notice: "#{@user.login_name}の就職活動中の情報を更新しました。"
    else
      redirect_to talk_url, alert: "#{@user.login_name}の就職活動中の情報を更新できませんでした。"
    end
  end

  private

  def allow_show_talk_page_only_admin
    return if current_user.admin? || @talk.user == current_user

    redirect_to talk_path(current_user.talk)
  end

  def set_talk
    @talk = Talk.find(params[:id])
  end

  def set_user
    @user = current_user.admin? ? @talk.user : current_user
  end

  def set_members
    @members = User.where(id: User.admins.ids.push(@talk.user_id))
                   .eager_load([:company, { avatar_attachment: :blob }])
                   .order(:id)
  end

  def user_params
    params.require(:user).permit(:job_seeking)
  end
end
