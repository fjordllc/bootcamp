# frozen_string_literal: true

class API::Companies::UsersController < API::BaseController
  TARGETS = %w[all student_and_trainee graduate adviser mentor].freeze
  before_action :require_login

  def index
    @target = params[:target]
    @target = 'student_and_trainee' unless TARGETS.include?(@target)
    @company = Company.find(params[:company_id])

    target_users = User.users_role(@target)

    @users = target_users.with_attached_avatar.where(company: @company).order(updated_at: :desc).page(params[:page])
  end
end
