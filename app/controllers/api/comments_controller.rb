# frozen_string_literal: true

class API::CommentsController < API::BaseController
  before_action :require_login
  before_action :set_my_comment, only: %i(update destroy)

  def index
    @comments = commentable.comments.order(created_at: :asc)
    @available_emojis = Reaction.emojis.map { |key, value| { kind: key, value: value } }
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    @comment.commentable = commentable
    @available_emojis = Reaction.emojis.map { |key, value| { kind: key, value: value } }
    if @comment.save
      notify_to_slack(@comment)
      render :create, status: :created
    else
      head :bad_request
    end
  end

  def update
    if @comment.update(comment_params)
      head :ok
    else
      head :bad_request
    end
  end

  def destroy
    @comment.destroy!
  end

  private

    def comment_params
      params.require(:comment).permit(:description)
    end

    def commentable
      params[:commentable_type].constantize.find(params[:commentable_id])
    end

    def set_my_comment
      @comment = current_user.comments.find(params[:id])
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
