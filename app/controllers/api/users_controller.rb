# frozen_string_literal: true

class API::UsersController < API::BaseController
  before_action :set_user, only: %i[show update]
  before_action :require_login_for_api
  PAGER_NUMBER = 24

  def index
    @tag = params[:tag]
    @company = params[:company_id]
    @watch = params[:watch]

    @target = target_allowlist.include?(params[:target]) ? params[:target] : 'student_and_trainee'

    target_users = retrieve_target_users
    @users = target_users
             .preload(:company, :avatar_attachment, :course, :tags)
             .order(updated_at: :desc)
             .page(params[:page])
             .per(PAGER_NUMBER)

    @users = search_for_users(@target, target_users, params[:search_word]) if params[:search_word]
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

  def search_for_users(target, target_users, search_word)
    users = target_users.search_by_keywords({ word: search_word })
    if target == 'retired'
      users = User.search_by_keywords({ word: search_word }).unscope(where: :retired_on)
                  .users_role(target, allowed_targets: target_allowlist, default_target: 'student_and_trainee')
    end
    users
  end

  def target_allowlist
    target_allowlist = %w[student_and_trainee followings mentor graduate adviser trainee year_end_party]
    target_allowlist.push('job_seeking') if current_user.adviser?
    target_allowlist.push('all') if @company
    target_allowlist.concat(%w[job_seeking hibernated retired inactive all]) if current_user.mentor? || current_user.admin?
    target_allowlist
  end

  def retrieve_target_users
    target_users =
      if @target == 'followings'
        current_user.followees_list(watch: @watch)
      elsif @tag
        User.tagged_with(@tag)
      elsif @company
        User.where(company_id: @company).users_role(@target, allowed_targets: target_allowlist, default_target: 'student_and_trainee')
      elsif @target.in? %w[hibernated retired]
        User.users_role(@target, allowed_targets: target_allowlist, default_target: 'student_and_trainee')
      else
        User.users_role(@target, allowed_targets: target_allowlist, default_target: 'student_and_trainee').unhibernated.unretired
      end

    @target == 'inactive' ? target_users.order(:last_activity_at) : target_users
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:tag_list)
  end
end
