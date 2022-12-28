# frozen_string_literal: true

class API::UsersController < API::BaseController
  before_action :set_user, only: %i[show update]
  before_action :require_login_for_api
  PAGER_NUMBER = 24

  def index
    @tag = params[:tag]
    @company = params[:company_id]
    @target = params[:target]
    @watch = params[:watch]

    @target = 'student_and_trainee' unless target_allowlist.include?(@target)

    target_users =
      if @target == 'followings'
        current_user.followees_list(watch: @watch)
      elsif params[:tag]
        User.tagged_with(params[:tag])
      elsif @company
        User.where(company_id: @company).users_role(@target)
      elsif @target == 'retired'
        User.users_role(@target)
      else
        User.users_role(@target).unhibernated.unretired
      end

    @users = target_users.page(params[:page]).per(PAGER_NUMBER)
                         .preload(:company, :avatar_attachment, :course, :tags)
                         .order(updated_at: :desc)
    if params[:search_word]
      @users = 
        if @target == 'retired'
          User.search_by_keywords({ word: params[:search_word] })
              .unscope(where: :retired_on)
              .users_role(@target)
        else
          target_users.search_by_keywords({ word: params[:search_word] })
        end
    end
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
    target_allowlist.push('all') if @company
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
