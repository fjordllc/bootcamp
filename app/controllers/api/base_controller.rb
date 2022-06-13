# frozen_string_literal: true

class API::BaseController < ApplicationController
  before_action :require_login_for_api, if: :not_before_user_icon_urls_controller?

  def not_before_user_icon_urls_controller?
    true
  end
end
