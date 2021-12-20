# frozen_string_literal: true

class API::Admin::BaseController < ApplicationController
  before_action :require_admin_login_for_api
end
