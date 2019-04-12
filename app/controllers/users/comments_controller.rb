# frozen_string_literal: true

class Users::CommentsController < MemberAreaController
  before_action :set_user
  before_action :set_comments

  def index
  end

  private
    def set_user
      @user = User.find(params[:user_id])
    end

    def set_comments
      @comments =
        Comment
          .preload(:commentable)
          .eager_load(:user)
          .where(user_id: user)
          .order(created_at: :desc).page(params[:page])
    end

    def user
      @user ||= User.find(params[:user_id])
    end
end
