# frozen_string_literal: true

class API::ReactionsController < API::BaseController
  before_action :set_reactionable, only: %i[create index]
  before_action -> { doorkeeper_authorize! :write }, only: %i[create destroy], if: -> { doorkeeper_token.present? }

  def create
    return render_not_found('リアクション対象が見つかりません。') unless @reactionable

    reaction = @reactionable.reactions.build(user: current_user, kind: params[:kind])

    if reaction.save
      render json: { id: reaction.id }, status: :created
    else
      render_validation_errors(reaction)
    end
  end

  def destroy
    reaction = current_user.reactions.find(params[:id])
    reaction.destroy
    render json: {}, status: :ok
  end

  def index
    return render_not_found('リアクション対象が見つかりません。') unless @reactionable

    render json: reaction_summary_json(@reactionable)
  end

  private

  def set_reactionable
    gid = params[:reactionable_gid]
    @reactionable = GlobalID::Locator.locate(gid)
  end
end
