# frozen_string_literal: true

class CommentsController < ApplicationController
  include Rails.application.routes.url_helpers
  include CommentsHelper
  include Gravatarify::Helper
  before_action :set_user, only: :show
  before_action :set_my_comment, only: %i(edit update destroy)

  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    @comment.commentable = commentable
    if @comment.save
      notify_to_slack(@comment)
      redirect_to commentable_url(@comment), notice: t("comment_was_successfully_created")
    else
      render :new
    end
  end

  def edit
    @comment = Comment.find(params[:id])
  end

  def update
    @comment = Comment.find(params[:id])

    if @comment.update(comment_params)
      redirect_to commentable_url(@comment), notice: t("comment_was_successfully_updated")
    else
      render :edit
    end
  end

  def destroy
    @comment = current_user.comments.find(params[:id])
    @comment.destroy
    redirect_to commentable_url(@comment), notice: t("comment_was_successfully_deleted")
  end

  private
    def comment_params
      params.require(:comment).permit(
        :description,
        :commentable_id,
        :commentable_type
      )
    end

    def set_user
      @user = User.find_by(id: params[:user_id])
    end

    def set_my_comment
      @comment = current_user.comments.find(params[:id])
    end

    def commentable
      klass = params[:comment][:commentable_type].constantize
      klass.find(params[:comment][:commentable_id])
    end

    def notify_to_slack(comment)
      name = "#{comment.user.login_name}"
      link = "<#{commentable_url(comment)}#comment_#{comment.id}|#{comment.commentable.title}>"

      notify "#{name} commented to #{link}",
        username: "#{comment.user.login_name} (#{comment.user.full_name})",
        icon_url: gravatar_url(comment.user, secure: true),
        attachments: [{
          fallback: "comment body.",
          text: comment.description
        }]
    end
end
