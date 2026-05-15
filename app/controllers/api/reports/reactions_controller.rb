# frozen_string_literal: true

class API::Reports::ReactionsController < API::BaseController
  before_action :set_report
  before_action -> { doorkeeper_authorize! :write }, only: %i[create destroy], if: -> { doorkeeper_token.present? }

  def index
    reactions = @report.reactions.includes(user: { avatar_attachment: :blob }).order(created_at: :asc)
    grouped_reactions = reactions.group_by(&:kind)
    result = Reaction.emojis.each_with_object({}) do |(kind, emoji), hash|
      users = grouped_reactions[kind]&.map { |reaction| user_payload(reaction.user) } || []
      hash[kind] = { emoji:, users: } unless users.empty?
    end
    render json: result
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

  def user_payload(user)
    user = ActiveDecorator::Decorator.instance.decorate(user)
    {
      id: user.id,
      login_name: user.login_name,
      avatar_url: user.avatar_url,
      user_icon_frame_class: user.user_icon_frame_class
    }
  end
end
