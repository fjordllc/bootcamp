# frozen_string_literal: true

class API::CommentsController < API::BaseController
  before_action :set_my_comment, only: %i[update destroy]
  before_action :set_available_emojis, only: %i[index create]

  def index
    @comments = commentable.comments.order(created_at: :desc)
    @comment_total_count = @comments.size
    @comments = @comments.limit(params[:comment_limit]) if params[:comment_limit].to_i > -1
    @comments = @comments.offset(params[:comment_offset]) if params[:comment_offset].to_i > -1
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    @comment.commentable = commentable
    if @comment.save
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
    params[:commentable_type].constantize.find_by(id: params[:commentable_id])
  end

  def set_my_comment
    @comment = current_user.admin? ? Comment.find(params[:id]) : current_user.comments.find(params[:id])
  end
end
