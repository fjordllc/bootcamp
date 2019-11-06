# frozen_string_literal: true

class CurrentUserController < ApplicationController
  before_action :require_login
  before_action :set_user

  def edit
    @companies = Company.all
  end

  def update
    if @user.update(user_params)
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
        :first_name,
        :last_name,
        :kana_first_name,
        :kana_last_name,
        :email,
        :course_id,
        :description,
        :job_seeking,
        :slack_account,
        :github_account,
        :twitter_account,
        :facebook_url,
        :blog_url,
        :feed_url,
        :password,
        :password_confirmation,
        :job,
        :organization,
        :os,
        :study_place,
        :experience,
        :prefecture_code,
        :company_id,
        :nda,
        :avatar,
        :trainee,
        :mail_notification
      )
    end

    def set_user
      @user = current_user
    end
end
