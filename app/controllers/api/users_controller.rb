# frozen_string_literal: true

class API::UsersController < API::BaseController
  before_action :require_login, only: %i[index]
  before_action :require_mentor_login_for_api, only: %i[update]
  PAGER_NUMBER = 20

  def index
    @tag = params[:tag]
    @target = params[:target]
    @target = 'student_and_trainee' unless target_allowlist.include?(@target)

    target_users =
      if @target == 'followings'
        followings = Following.where(follower_id: current_user.id).select('followed_id')
        User.where(id: followings)
      elsif params[:tag]
        User.tagged_with(params[:tag])
      else
        User.users_role(@target)
      end

    @users = target_users
             .page(params[:page]).per(PAGER_NUMBER)
             .preload(:company, :avatar_attachment, :course, :tags)
             .unretired
             .order(updated_at: :desc)
  end

  def show
    @user = User.find(params[:id])
  end

<<<<<<< HEAD
  private

  def target_allowlist
    target_allowlist = %w[student_and_trainee followings mentor graduate adviser trainee year_end_party]
    target_allowlist.push('job_seeking') if current_user.adviser?
    target_allowlist.concat(%w[job_seeking retired inactive all]) if current_user.mentor? || current_user.admin?
    target_allowlist
  end
=======
  def update
    @user = User.find(params[:id])
    if @user.update_mentor_memo(user_params[:mentor_memo])
      head :ok
    else
      head :bad_request
    end
  end

  private

<<<<<<< HEAD
    def user_params
      params.require(:users).permit(:memo)
    end
>>>>>>> a593ce12b (ユーザーapiコントローラーにupdate処理を追加)
=======
  def user_params
    params.require(:user).permit(:mentor_memo)
  end
>>>>>>> 4e92003ea (メモを保存した場合、updated_atカラムを更新しない処理を追加)
end
