# frozen_string_literal: true

class API::BaseController < ApplicationController
  skip_before_action :require_active_user_login, raise: false
  skip_before_action :verify_authenticity_token, if: -> { doorkeeper_token.present? }
  before_action :doorkeeper_authorize!, if: -> { doorkeeper_token.present? }
  before_action :require_login_for_api, unless: -> { doorkeeper_token.present? }

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
end
