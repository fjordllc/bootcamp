# frozen_string_literal: true

class Users::GenerationsController < ApplicationController
  TARGETS = %w[all trainee adviser graduate mentor]
  before_action :require_login

  def index
    @target = params[:target]
    @target = TARGETS

    target_users = User.users_role(@target)

    @users = target_users
             .page(params[:page]).per(PAGER_NUMBER)
             .preload(:avatar_attachment, :course, :taggings)
             .unretired
             .order(updated_at: :desc)
  end
end
