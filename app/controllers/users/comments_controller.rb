# frozen_string_literal: true

class Users::CommentsController < ApplicationController
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
          .where(user_id: user, commentable_type: "Report")
          .paging_with_created_at(page: params[:page], order_type: "desc")
    end

    def user
      @user ||= User.find(params[:user_id])
    end
end
