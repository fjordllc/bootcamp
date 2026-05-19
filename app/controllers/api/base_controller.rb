# frozen_string_literal: true

class API::BaseController < ApplicationController
  skip_before_action :require_active_user_login, raise: false
  skip_before_action :verify_authenticity_token, if: -> { doorkeeper_token.present? }
  before_action :doorkeeper_authorize!, if: -> { doorkeeper_token.present? }
  before_action :require_login_for_api, unless: -> { doorkeeper_token.present? }
  rescue_from Doorkeeper::Errors::DoorkeeperError, with: :render_doorkeeper_error

  private

  def current_user
    super || current_resource_owner
  end

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def current_action_name
    "#{self.class.name}##{action_name}"
  end

  def render_validation_errors(resource)
    render json: { errors: resource.errors }, status: :unprocessable_entity
  end

  def render_not_found(message = 'リソースが見つかりません。')
    render json: { message: }, status: :not_found
  end

  def render_bad_request(message = 'リクエストが不正です。')
    render json: { message: }, status: :bad_request
  end

  def check_json(check)
    {
      id: check.id,
      checkable_type: check.checkable_type,
      checkable_id: check.checkable_id,
      user: {
        id: check.user.id,
        login_name: check.user.login_name,
        name: check.user.name
      },
      created_at: check.created_at
    }
  end

  def reaction_summary_json(reactionable)
    reactions = reactionable.reactions.includes(user: { avatar_attachment: :blob }).order(created_at: :asc)
    grouped_reactions = reactions.group_by(&:kind)

    Reaction.emojis.each_with_object({}) do |(kind, emoji), hash|
      users = grouped_reactions[kind]&.map { |reaction| reaction_user_json(reaction.user) } || []
      hash[kind] = { emoji:, users: } unless users.empty?
    end
  end

  def require_login_for_api
    login_from_jwt unless logged_in?
    render json: { error: 'unauthorized' }, status: :unauthorized unless logged_in?
  end

  def doorkeeper_unauthorized_render_options(error:)
    { json: doorkeeper_error_body(error) }
  end

  def doorkeeper_forbidden_render_options(error:)
    { json: doorkeeper_error_body(error) }
  end

  def render_doorkeeper_error(error)
    response = error.response
    render json: doorkeeper_error_body(error), status: response.status
  end

  def doorkeeper_error_body(error)
    {
      error: error.name,
      error_description: error.description,
      state: error.state
    }.compact_blank
  end

  def reaction_user_json(user)
    user = ActiveDecorator::Decorator.instance.decorate(user)
    {
      id: user.id,
      login_name: user.login_name,
      avatar_url: user.avatar_url,
      user_icon_frame_class: user.user_icon_frame_class
    }
  end
end
