# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :set_comment, only: %i[destroy]
  before_action :authorize_comment, only: %i[destroy]

  def destroy
    @comment.destroy!
  end

  private

  def set_comment
    @comment = current_user.admin? || current_user.mentor? ? Comment.find(params[:id]) : current_user.comments.find(params[:id])
  end

  def authorize_comment
    return if @comment.visible_to_user?(current_user)

    head :forbidden
  end
end
