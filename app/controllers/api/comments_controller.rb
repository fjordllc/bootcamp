# frozen_string_literal: true

class API::CommentsController < API::BaseController
  before_action :set_my_comment, only: %i[update destroy]
  before_action :set_available_emojis, only: %i[index create]
  before_action -> { doorkeeper_authorize! :write }, only: %i[create update destroy], if: -> { doorkeeper_token.present? }

  def index
    if params[:commentable_type].present?
      return if commentable.comments.nil?

      @comments = commentable.comments.order(created_at: :desc)
      @comment_total_count = @comments.size
      @comments = @comments.limit(params[:comment_limit])
                           .offset(params[:comment_offset])
    else
      render_bad_request
    end
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    @comment.commentable = commentable
    if @comment.save
      render json: comment_json(@comment), status: :created
    else
      render_validation_errors(@comment)
    end
  end

  def update
    if @comment.update(comment_params)
      render json: comment_json(@comment), status: :ok
    else
      render_validation_errors(@comment)
    end
  end

  def destroy
    @comment.destroy!
    render json: { id: @comment.id }, status: :ok
  end

  private

  def comment_params
    params.require(:comment).permit(:description)
  end

  def commentable
    params[:commentable_type].constantize.find(params[:commentable_id])
  end

  def set_my_comment
    @comment = current_user.admin? || current_user.mentor? ? Comment.find_by(id: params[:id]) : current_user.comments.find_by(id: params[:id])
    render_not_found('コメントが見つかりません。') unless @comment
  end

  def comment_json(comment)
    {
      id: comment.id,
      description: comment.description,
      commentable_type: comment.commentable_type,
      commentable_id: comment.commentable_id,
      user: {
        id: comment.user.id,
        login_name: comment.user.login_name,
        name: comment.user.name
      },
      created_at: comment.created_at,
      updated_at: comment.updated_at
    }
  end
end
