# frozen_string_literal: true

class API::Mentor::BaseController < ApplicationController
  skip_before_action :require_active_user_login, raise: false
  before_action :require_mentor_login_for_api
end
