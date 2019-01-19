# frozen_string_literal: true

class Admin::UsersController < AdminController
  before_action :set_user, only: %i(edit update)

  def index
    @users = User.order(updated_at: :desc)
    @target = params[:target] || "student"
    @users = User.users_role(@users, @target)
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_users_url, notice: "ユーザー情報を更新しました。"
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
        :adviser,
        :login_name,
        :first_name,
        :last_name,
        :email,
        :course_id,
        :description,
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
        :how_did_you_know,
        :company_id,
        :trainee,
        :nda,
        :graduated_on,
        :retired_on
      )
    end
end
