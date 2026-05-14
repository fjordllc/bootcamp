# frozen_string_literal: true

class API::Reports::CommentsController < API::BaseController
  before_action :set_available_emojis, only: %i[create]
  before_action -> { doorkeeper_authorize! :write }, only: %i[create], if: -> { doorkeeper_token.present? }

  def create
    report = Report.find_by(id: params[:report_id])
    return render json: { message: '日報が見つかりません。' }, status: :not_found unless report

    @comment = report.comments.new(comment_params)
    @comment.user = current_user

    if @comment.save
      render 'api/comments/create', status: :created
    else
      render json: { errors: @comment.errors }, status: :unprocessable_entity
    end
  end

  private

  def comment_params
    params.fetch(:comment, ActionController::Parameters.new).permit(:description)
  end
end
