# frozen_string_literal: true

class API::ReactionsController < API::BaseController
  before_action :set_reactionable, only: %i[create index]

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

    reactions = @reactionable
                .reactions
                .includes(user: { avatar_attachment: :blob }).order(created_at: :asc)
    grouped_reactions = reactions.group_by(&:kind)
    result = Reaction.emojis.each_with_object({}) do |(kind, emoji), hash|
      users = grouped_reactions[kind]&.map { |reaction| user_payload(reaction.user) } || []
      hash[kind] = { emoji:, users: } unless users.empty?
    end
    render json: result
  end

  private

  def set_reactionable
    gid = params[:reactionable_gid]
    @reactionable = GlobalID::Locator.locate(gid)
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
