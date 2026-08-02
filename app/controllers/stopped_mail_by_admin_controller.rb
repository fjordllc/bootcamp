# frozen_string_literal: true

class StoppedMailByAdminController < ApplicationController
  skip_before_action :require_active_user_login, raise: false
  before_action :set_user, only: %i[update]
  before_action :set_redirect_url, only: %i[update]
  before_action :require_admin_login, only: %i[update]

  def update
    mail_status = params[:stopped_mail_by_admin].present?
    if @user.update(stopped_mail_by_admin: mail_status)
      redirect_to @redirect_url, notice: 'ユーザー情報を更新しました。'
    else
      redirect_to @redirect_url, alert: 'ユーザー情報の更新に失敗しました'
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_redirect_url
    @redirect_url = url_from(params[:redirect_url]) || admin_users_url
  end
end
