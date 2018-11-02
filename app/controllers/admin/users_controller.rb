# frozen_string_literal: true

class Admin::UsersController < AdminController
  before_action :set_user, only: %i(show edit update)

  def index
    @users = User.all
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_users_url, notice: "ユーザーを更新しました。"
    else
      render :edit
    end
  end

  def destroy
    # 今後本人退会時に処理が増えることを想定し、自分自身は削除できないよう
    # 制限をかけておく
    redirect_to admin_users_url, alert: "自分自身を削除する場合、退会から処理を行ってください。" if current_user.id == params[:id]
    begin
      user = User.find(params[:id])
      user.destroy
      redirect_to admin_users_url, notice: "#{user.full_name} さんを削除しました。"
    rescue => e
      Rails.logger.error e.class
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.join("\n")
      redirect_to admin_users_url, alert: "ユーザー削除時にエラーが発生しました。"
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(
        :login_name,
        :email,
        :first_name,
        :last_name,
        :password,
        :password_confirmation,
        :twitter_account,
        :facebook_url,
        :github_account,
        :slack_account,
        :blog_url,
        :company_id,
        :description,
        :find_job_assist,
        :feed_url,
        :graduation,
        :adviser,
        :retire,
        :nda
      )
    end
end
