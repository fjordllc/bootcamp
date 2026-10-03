# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :set_comment, only: %i[update destroy]

  def create
    @commentable = params[:commentable_type].constantize.find(params[:commentable_id])
    @comment = current_user.comments.build(comment_params.merge(commentable: @commentable))

    head :unprocessable_entity unless @comment.save
  end

  def update
    head :unprocessable_entity unless @comment.update(comment_params)
  end

  def destroy
    @comment.destroy!
  end

  private

  def comment_params
    params.require(:comment).permit(:description)
  end

  def set_comment
    @comment = current_user.admin? || current_user.mentor? ? Comment.find(params[:id]) : current_user.comments.find(params[:id])
  end
end
