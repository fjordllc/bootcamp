# frozen_string_literal: true

class API::CommentsController < API::BaseController
  include CommentableController

  def index
    @comments = commentable.comments.order(created_at: :desc)
  end

  private

  def commentable
    params[:commentable_type].constantize.find(params[:commentable_id])
  end
end
