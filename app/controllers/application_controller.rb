# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authentication
  protect_from_forgery
  before_action :init_user
  before_action :allow_cross_domain_access
  helper_method :product_displayable?

  protected
    def product_displayable?(practice: nil, user: nil)
      return true if admin_login? || mentor_login? || adviser_login?
      if user
        user == current_user || user.has_checked_product_of?(current_user.practices_with_checked_product)
      else
        current_user.has_checked_product_of?(practice)
      end
    end

    def allow_cross_domain_access
      response.headers["Access-Control-Allow-Origin"] = "*"
      response.headers["Access-Control-Allow-Methods"] = "*"
    end

  private
    def init_user
      @current_user = User.find(current_user.id) if current_user
    end
end
