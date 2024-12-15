# frozen_string_literal: true

class API::UsersController < API::BaseController
  before_action :set_user, only: %i[show update]
  before_action :require_login_for_api, except: :show
  before_action :doorkeeper_authorize!, only: :show
  PAGER_NUMBER = 24

  def index
    @tag = params[:tag]
    @company = params[:company_id]
    @watch = params[:watch]

    @target = target_allowlist.include?(params[:target]) ? params[:target] : 'student_and_trainee'

    users = target_users
    users = users.order(:last_activity_at) if @target == 'inactive'
    @users =
      if params[:search_word]
        search_for_users(@target, users, params[:search_word])
      else
        users
          .preload(:company, :avatar_attachment, :course, :tags)
          .order(updated_at: :desc)
          .page(params[:page])
          .per(PAGER_NUMBER)
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

  def search_for_users(target, target_users, search_word)
    users = target_users.search_by_keywords({ word: search_word })
    # search_by_keywords内では { unretired } というスコープが設定されている
    # 退会したユーザーに対しキーワード検索を行う場合は、一旦 unscope(where: :retired_on) で { unretired } スコープを削除し、その後で retired スコープを設定する必要がある
    target == 'retired' ? users.unscope(where: :retired_on).retired : users
  end

  def target_allowlist
    target_allowlist = %w[student_and_trainee student trainee followings mentor graduate adviser year_end_party admin]
    target_allowlist.push('job_seeking') if current_user.adviser?
    target_allowlist.push('all') if @company
    target_allowlist.concat(%w[job_seeking hibernated retired inactive all]) if current_user.mentor? || current_user.admin?
    target_allowlist
  end

  def target_users
    if @target == 'followings'
      current_user.followees_list(watch: @watch)
    elsif @tag
      User.tagged_with(@tag).unhibernated.unretired
    else
      users_scope =
        if @company
          User.where(company_id: @company)
        elsif @target.in? %w[hibernated retired]
          User
        else
          User.unhibernated.unretired
        end
      users_scope.users_role(@target, allowed_targets: target_allowlist)
    end
  end

  def set_user
    @user = if params[:id] == 'show'
              User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
            else
              User.find(params[:id])
            end
  end

  def user_params
    params.require(:user).permit(:tag_list)
  end
end
