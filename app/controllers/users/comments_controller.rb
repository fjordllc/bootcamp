# frozen_string_literal: true

class Users::CommentsController < ApplicationController
  before_action :require_login
  before_action :set_user
  before_action :set_comments

  def index; end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_comments
    @comments =
      Comment
      .where.not(commentable_type: 'Talk')
      .preload(commentable: { user: { avatar_attachment: :blob } })
      .eager_load(:user)
      .where(user_id: user)
      .order(created_at: :desc).page(params[:page])
  end

  def user
    @user ||= User.find(params[:user_id])
  end
end
