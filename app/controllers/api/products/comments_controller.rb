# frozen_string_literal: true

class API::Products::CommentsController < API::BaseController
  before_action -> { doorkeeper_authorize! :write }, only: %i[create], if: -> { doorkeeper_token.present? }

  def create
    product = Product.find_by(id: params[:product_id])
    return render json: { message: '提出物が見つかりません。' }, status: :not_found unless product

    comment = product.comments.new(comment_params)
    comment.user = current_user

    if comment.save
      render json: comment_json(comment), status: :created
    else
      render json: { errors: comment.errors }, status: :unprocessable_entity
    end
  end

  private

  def comment_params
    params.fetch(:comment, ActionController::Parameters.new).permit(:description)
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
