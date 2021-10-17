# frozen_string_literal: true

class API::UsersController < API::BaseController
  before_action :set_user, only: %i[show update]
  before_action :require_login_for_api
  PAGER_NUMBER = 20

  def index
    @tag = params[:tag]
    @target = params[:target]
    @target = 'student_and_trainee' unless target_allowlist.include?(@target)
    @watch = params[:watch]

    target_users =
      if @target == 'followings'
        current_user.followees_list(watch: @watch)
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

  def show; end

  def update
    if @user == current_user && @user.update(user_params)
      head :ok
    else
      head :bad_request
    end
  end

  private

  def target_allowlist
    target_allowlist = %w[student_and_trainee followings mentor graduate adviser trainee year_end_party]
    target_allowlist.push('job_seeking') if current_user.adviser?
    target_allowlist.concat(%w[job_seeking retired inactive all]) if current_user.mentor? || current_user.admin?
    target_allowlist
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:tag_list)
  end
end
