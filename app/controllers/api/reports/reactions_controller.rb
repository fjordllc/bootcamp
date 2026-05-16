# frozen_string_literal: true

class API::Reports::ReactionsController < API::BaseController
  before_action :set_report
  before_action -> { doorkeeper_authorize! :write }, only: %i[create destroy], if: -> { doorkeeper_token.present? }

  def index
    render json: reaction_summary_json(@report)
  end

  def create
    reaction = @report.reactions.build(user: current_user, kind: params[:kind])

    if reaction.save
      render json: { id: reaction.id }, status: :created
    else
      render json: { errors: reaction.errors }, status: :unprocessable_entity
    end
  rescue ArgumentError
    render json: { errors: { kind: ['利用できない絵文字です。'] } }, status: :unprocessable_entity
  end

  def destroy
    reaction = current_user.reactions.find_by(id: params[:id], reactionable: @report)
    return render json: { message: 'リアクションが見つかりません。' }, status: :not_found unless reaction

    reaction.destroy
    render json: {}, status: :ok
  end

  private

  def set_report
    @report = Report.find_by(id: params[:report_id])
    render json: { message: '日報が見つかりません。' }, status: :not_found unless @report
  end
end
