# frozen_string_literal: true

class API::BaseController < ApplicationController
  skip_before_action :require_active_user_login, raise: false
  before_action :require_login_for_api

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

  def require_admin_or_mentor_login_for_api
    return if current_user.admin_or_mentor?

    render json: { error: '権限がありません' }, status: :forbidden
  end
end
