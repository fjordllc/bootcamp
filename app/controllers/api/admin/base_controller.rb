# frozen_string_literal: true

class Api::Admin::BaseController < ApplicationController
  skip_before_action :require_active_user_login, raise: false
  before_action :require_admin_login_for_api
end
