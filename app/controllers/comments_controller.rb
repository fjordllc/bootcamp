# frozen_string_literal: true

class CommentsController < ApplicationController
  def create
    @commentable = params[:commentable_type].constantize.find(params[:commentable_id])
    @comment = current_user.comments.build(comment_params.merge(commentable: @commentable))

    head :unprocessable_entity unless @comment.save
  end

  private

  def comment_params
    params.require(:comment).permit(:description)
  end
end
