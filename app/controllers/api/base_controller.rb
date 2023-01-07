# frozen_string_literal: true

class API::BaseController < ApplicationController
  skip_before_action :require_login, raise: false
  skip_before_action :require_current_student, raise: false
  before_action :require_login_for_api
end
