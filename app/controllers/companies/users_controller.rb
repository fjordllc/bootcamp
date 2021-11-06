# frozen_string_literal: true

class Companies::UsersController < ApplicationController
  before_action :require_login

  def index
    @target = params[:target]
    @target = 'student_and_trainee' unless target_allowlist.include?(@target)
    @company = Company.find(params[:company_id])

    target_users =
      if params[:tag]
        User.tagged_with(params[:tag])
      else
        User.users_role(@target)
      end

    @users = target_users.with_attached_avatar.where(company: @company).order(updated_at: :desc)
  end

  private

  def target_allowlist
    %w[student_and_trainee all]
  end
end
