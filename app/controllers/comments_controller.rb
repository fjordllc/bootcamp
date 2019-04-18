# frozen_string_literal: true

class CommentsController < ApplicationController
  include Rails.application.routes.url_helpers
  before_action :set_user, only: :show
  before_action :set_my_comment, only: %i(edit update destroy)

  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    @comment.commentable = commentable
    if @comment.save
      notify_to_slack(@comment)
      redirect_to @comment.commentable, notice: "コメントを投稿しました。"
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
      redirect_to @comment.commentable, notice: "コメントを更新しました。"
    else
      render :edit
    end
  end

  def destroy
    @comment = current_user.comments.find(params[:id])
    @comment.destroy
    redirect_to @comment.commentable, notice: "コメントを削除しました。"
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
      link = "<#{polymorphic_url(comment.commentable)}#comment_#{comment.id}|#{comment.commentable.title}>"

      SlackNotification.notify "#{name} commented to #{link}",
        username: "#{comment.user.login_name} (#{comment.user.full_name})",
        icon_url: url_for(comment.user.avatar),
        attachments: [{
          fallback: "comment body.",
          text: comment.description
        }]
    end
end
