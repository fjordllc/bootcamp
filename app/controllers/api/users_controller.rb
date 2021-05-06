# frozen_string_literal: true

class API::UsersController < API::BaseController
  before_action :require_login, only: %i[index]

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
            .page(params[:page])
            .preload(:company, :avatar_attachment, :course, :tags)
            .unretired
            .order(updated_at: :desc)

    # users = User.select(:login_name, :name)
    #             .order(updated_at: :desc)
    #             .as_json(except: :id)
    # render json: users
  end

  def show
    @user = User.find(params[:id])
  end

  private

  def target_allowlist
    target_allowlist = %w[student_and_trainee followings mentor graduate adviser trainee year_end_party]
    target_allowlist.push('job_seeking') if current_user.adviser?
    target_allowlist.concat(%w[job_seeking retired inactive all]) if current_user.mentor? || current_user.admin?
    target_allowlist
  end
end
