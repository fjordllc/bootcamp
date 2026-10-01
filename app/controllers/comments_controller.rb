# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :set_comment, only: %i[destroy]

  def destroy
    @comment.destroy!
  end

  private

  def set_comment
    @comment = current_user.admin? || current_user.mentor? ? Comment.find(params[:id]) : current_user.comments.find(params[:id])
  end
end
