# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :set_comment, only: %i[update destroy]
  before_action :validate_commentable_type, only: %i[create]
  before_action :authorize_commentable, only: %i[create]
  before_action :authorize_comment, only: %i[update destroy]

  def create
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

  def validate_commentable_type
    head :bad_request unless Comment.commentable_class(params[:commentable_type])
  end

  def authorize_commentable
    @commentable = Comment.commentable_class(params[:commentable_type]).find(params[:commentable_id])
    return if Comment.new(commentable: @commentable).visible_to_user?(current_user)

    head :forbidden
  end

  def authorize_comment
    return if @comment.visible_to_user?(current_user)

    head :forbidden
  end
end
