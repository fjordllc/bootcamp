# frozen_string_literal: true

class API::Companies::UsersController < API::BaseController
  before_action :require_login
  TARGETS = %w[all student_and_trainee graduate adviser mentor].freeze
  PAGER_NUMBER = 20

  def index
    @target = params[:target]
    @target = 'student_and_trainee' unless TARGETS.include?(@target)
    @company = Company.find(params[:company_id])

    target_users = User.users_role(@target)

    @users = target_users.with_attached_avatar.where(company: @company).order(updated_at: :desc).page(params[:page]).per(PAGER_NUMBER)
  end
end
