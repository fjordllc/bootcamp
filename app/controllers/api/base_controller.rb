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
    render json: response.body, status: response.status
  end

  def doorkeeper_error_body(error)
    {
      error: error.name,
      error_description: error.description,
      state: error.state
    }.compact_blank
  end
end
