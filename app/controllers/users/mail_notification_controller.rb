# frozen_string_literal: true

class Users::MailNotificationController < ApplicationController
  skip_before_action :require_active_user_login, raise: false
  before_action :set_user, only: %i[edit update]
  before_action :validate_user_access, only: %i[edit update]
  layout 'not_logged_in'

  def edit; end

  def update
    if @user.update(mail_notification: false)
      redirect_to root_path, notice: 'メール配信を停止しました。'
    else
      render :edit
    end
  end

  private

  def set_user
    @user = User.find_by(unsubscribe_email_token: params[:token])
  end

  def validate_user_access
    is_unauthorized_user_access = !@user || @user.id != params[:user_id].to_i
    redirect_to root_path, alert: 'ユーザーIDもしくはTOKENが違います。' if is_unauthorized_user_access
  end
end
