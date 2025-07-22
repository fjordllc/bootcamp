# frozen_string_literal: true

class API::ReactionsController < API::BaseController
  def create
    reactionables = params[:reactionable_id].split('_')
    reactionable_id = reactionables.pop
    reactionable_type = reactionables.join('_')
    reactionable = reactionable_type.camelcase.constantize.find(reactionable_id)
    reaction = reactionable.reactions.build(user: current_user, kind: params[:kind])

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
    reactionables = params[:reactionable_id].split('_')
    reactionable_id = reactionables.pop
    reactionable_type = reactionables.join('_')
    reactionable = reactionable_type.camelcase.constantize.find(reactionable_id)

    reactions = reactionable.reactions.includes(:user)
    result = Reaction.emojis.each_with_object({}) do |(kind, emoji), hash|
      users = reactions
              .select { |r| r.kind == kind.to_s }
              .map { |r| r.user.login_name }
      hash[kind] = { emoji:, users: } unless users.empty?
    end

    render json: result
  end
end
