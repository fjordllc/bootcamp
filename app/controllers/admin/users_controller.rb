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
        :purpose_cd,
        :feed_url,
        :graduation,
        :adviser,
        :retire,
        :nda
      )
    end
end
