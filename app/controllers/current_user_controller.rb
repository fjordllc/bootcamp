# frozen_string_literal: true

class CurrentUserController < ApplicationController
  before_action :require_login
  before_action :set_user

  def edit
    @companies = Company.all
  end

  def update
    if @user.update(user_params)
      @user.resize_avatar!
      redirect_to @user, notice: "ユーザー情報を更新しました。"
    else
      render "edit"
    end
  end

  private

    def user_params
      params.require(:user).permit(
        :adviser,
        :login_name,
        :name,
        :name_kana,
        :email,
        :course_id,
        :description,
        :job_seeking,
        :slack_account,
        :github_account,
        :twitter_account,
        :facebook_url,
        :blog_url,
        :password,
        :password_confirmation,
        :job,
        :organization,
        :os,
        :experience,
        :prefecture_code,
        :company_id,
        :nda,
        :avatar,
        :trainee,
        :mail_notification,
        :job_seeker
      )
    end

    def set_user
      @user = current_user
    end
end
