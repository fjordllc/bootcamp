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
end
