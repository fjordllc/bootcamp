# frozen_string_literal: true

class API::CommentsController < API::BaseController
  before_action :set_my_comment, only: %i[update destroy]
  before_action :set_available_emojis, only: %i[index create]
  skip_before_action :verify_authenticity_token, if: -> { doorkeeper_token.present? }
  before_action :doorkeeper_authorize!, if: -> { doorkeeper_token.present? }
  before_action -> { doorkeeper_authorize! :write }, only: %i[create update destroy], if: -> { doorkeeper_token.present? }

  def index
    if params[:commentable_type].present?
      return if commentable.comments.nil?

      @comments = commentable.comments.order(created_at: :desc)
      @comment_total_count = @comments.size
      @comments = @comments.limit(params[:comment_limit])
                           .offset(params[:comment_offset])
    else
      head :bad_request
    end
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    @comment.commentable = commentable
    if @comment.save
      # TODO: Inquiry以外はvueでJSONを使用している。コメント機能のJS変換が完了すれば下の'Inquiry'による分岐は不要なので削除してください。
      if params[:commentable_type] == 'Inquiry'
        render partial: 'comments/comment', locals: { commentable:, comment: @comment, user: current_user }, status: :created
      else
        render :create, status: :created
      end
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
    @comment = current_user.admin? ? Comment.find(params[:id]) : current_user.comments.find(params[:id])
  end
end
