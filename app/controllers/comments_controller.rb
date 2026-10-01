# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :set_comment, only: %i[update destroy]
  before_action :authorize_comment, only: %i[update destroy]

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

  def authorize_comment
    return if @comment.visible_to_user?(current_user)

    head :forbidden
  end
end
