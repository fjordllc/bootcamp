# frozen_string_literal: true

class Admin::UsersController < AdminController
  before_action :set_user, only: %i(show edit update)

  def index
    @users = User.order(updated_at: :desc)
    @target = params[:target] || "student"
    @users =
      case @target
      when "student"
        @users.student
      when "retired"
        @users.retired
      when "graduate"
        @users.graduated
      when "adviser"
        @users.advisers
      when "mentor"
        @users.mentor
      when "inactive"
        @users.where(adviser: false, retire: false, graduation: false).inactive.order(:updated_at)
      when "year_end_party"
        @users.where(retired_on: nil)
      when "all"
        @users
      end
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
    user = User.find(params[:id])
    user.destroy
    redirect_to admin_users_url, notice: "#{user.full_name} さんを削除しました。"
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
        :adviser,
        :nda,
        :graduated_on,
        :retired_on,
        :nda
      )
    end
end
