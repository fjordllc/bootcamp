# frozen_string_literal: true

class API::ReactionsController < API::BaseController
  before_action :set_reactionable, only: %i[create index]

  def create
    reaction = @reactionable.reactions.build(user: current_user, kind: params[:kind])

    if reaction.save
      render json: { id: reaction.id }, status: :created
    else
      head :bad_request
    end
  end

  def destroy
    reaction = current_user.reactions.find(params[:id])
    reaction.destroy
    render json: {}, status: :ok
  end

  def index
    return render json: {} unless @reactionable

    reactions = @reactionable.reactions.includes(:user)
    result = Reaction.emojis.each_with_object({}) do |(kind, emoji), hash|
      users = reactions
              .select { |r| r.kind == kind.to_s }
              .map { |r| r.user.login_name }
      hash[kind] = { emoji:, users: } unless users.empty?
    end

    render json: result
  end

  private

  def set_reactionable
    type_and_id = params[:reactionable_id].to_s.split('_')
    id = type_and_id.pop
    type = type_and_id.join('_')
    @reactionable = type.camelcase.constantize&.find_by(id:)
  end
end
