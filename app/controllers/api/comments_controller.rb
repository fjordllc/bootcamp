# frozen_string_literal: true

class API::CommentsController < API::BaseController
  before_action :set_my_comment, only: %i[update destroy]
  before_action :set_available_emojis, only: %i[index create]
  before_action :authorize_commentable, only: %i[index]
  before_action -> { doorkeeper_authorize! :write }, only: %i[create update destroy], if: -> { doorkeeper_token.present? }

  COMMENT_LIMIT = 8

  def index
    if params[:commentable_type].present?
      return if commentable.comments.nil?

      if request.format.html?
        render_comments_page
      else
        @comments = commentable.comments.order(created_at: :desc)
        @comment_total_count = @comments.size
        @comments = @comments.limit(params[:comment_limit])
                             .offset(params[:comment_offset])
      end
    else
      render_bad_request
    end
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    @comment.commentable = commentable
    if @comment.save
      render_created_comment
    else
      render_validation_errors(@comment)
    end
  end

  def update
    if @comment.update(comment_params)
      request.format.json? ? render(json: comment_json(@comment), status: :ok) : head(:ok)
    else
      render_validation_errors(@comment)
    end
  end

  def destroy
    @comment.destroy!
    request.format.json? ? render(json: { id: @comment.id }, status: :ok) : head(:no_content)
  end

  private

  def render_comments_page
    return head :bad_request unless params[:target] || params[:before]

    if params[:target]
      @comments = [commentable.comments.with_user_details.find(params[:target])]
      comment_remaining = 0
    else
      before = commentable.comments.find(params[:before])
      @comments = commentable.comments.with_user_details.before_comment(before)
                             .order(created_at: :desc, id: :desc)
                             .limit(COMMENT_LIMIT)
                             .to_a
                             .reverse
      comment_remaining = @comments.empty? ? 0 : commentable.comments.before_comment(@comments.first).count
    end
    response.set_header('X-Comment-Remaining', comment_remaining.to_s)
    render partial: 'comments/comment', collection: @comments, as: :comment,
           locals: { user: current_user, latest_comment: nil }
  end

  def authorize_commentable
    return if params[:commentable_type].blank?
    return if Comment.new(commentable:).visible_to_user?(current_user)

    head :forbidden
  end

  def comment_params
    params.require(:comment).permit(:description)
  end

  def commentable
    @commentable ||= params[:commentable_type].constantize.find(params[:commentable_id])
  end

  def set_my_comment
    @comment = current_user.admin? || current_user.mentor? ? Comment.find_by(id: params[:id]) : current_user.comments.find_by(id: params[:id])
    render_not_found('コメントが見つかりません。') unless @comment
  end

  def render_created_comment
    if request.format.json?
      render json: comment_json(@comment), status: :created
    else
      render partial: 'comments/comment',
             locals: { commentable:, comment: @comment, user: current_user, latest_comment: @comment },
             status: :created
    end
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
