# frozen_string_literal: true

class Companies::UsersController < ApplicationController
  PAGER_NUMBER = 24

  ALLOWED_TARGETS = %w[all student_and_trainee graduate adviser mentor admin].freeze

  def index
    @target = params[:target]
    @target = 'student_and_trainee' unless ALLOWED_TARGETS.include?(@target)
    @company = Company.find(params[:company_id])

    target_users = User.users_role(@target, allowed_targets: ALLOWED_TARGETS)
    @users = target_users.with_attached_avatar
                         .where(company: @company)
                         .order(updated_at: :desc)
                         .page(params[:page])
                         .per(PAGER_NUMBER)
  end
end
