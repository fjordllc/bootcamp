# frozen_string_literal: true

class Admin::UsersController < AdminController
  before_action :set_user, only: %i(show edit update)

  def index
    @direction = params[:direction] || "desc"
    @target = params[:target] || "student"
    @users = User.with_attached_avatar
                 .preload(%i[company course])
                 .order_by_counts(params[:order_by] || "id", @direction)
                 .users_role(@target)
  end

  def show
    render action: :show, layout: nil
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
        :kana_first_name,
        :kana_last_name,
        :email,
        :course_id,
        :description,
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
        :study_place,
        :experience,
        :prefecture_code,
        :company_id,
        :trainee,
        :job_seeking,
        :nda,
        :graduated_on,
        :retired_on,
        :free,
        :job_seeker,
        :slack_participation,
        :github_collaborator,
        :officekey_permission
      )
    end
end
