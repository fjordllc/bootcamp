# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authentication
  include PolicyHelper
  protect_from_forgery
  before_action :init_user
  before_action :allow_cross_domain_access

  protected
    def allow_cross_domain_access
      response.headers["Access-Control-Allow-Origin"] = "*"
      response.headers["Access-Control-Allow-Methods"] = "*"
    end

  private
    def init_user
      @current_user = User.find(current_user.id) if current_user
    end
end
