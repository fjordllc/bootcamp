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

    reactions = @reactionable
                .reactions
                .includes(user: { avatar_attachment: :blob }).order(created_at: :asc)
    result = Reaction.emojis.each_with_object({}) do |(kind, emoji), hash|
      users = reactions
              .select { |r| r.kind == kind.to_s }
              .map { |r| user_payload(r.user) }
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
