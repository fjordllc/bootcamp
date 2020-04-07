# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authentication
  include PolicyHelper
  protect_from_forgery with: :exception
  before_action :init_user
  before_action :allow_cross_domain_access
  before_action :set_host_for_disk_storage

  protected
    def allow_cross_domain_access
      response.headers["Access-Control-Allow-Origin"] = "*"
      response.headers["Access-Control-Allow-Methods"] = "*"
    end

  private
    def init_user
      @current_user = User.find(current_user.id) if current_user
    end

    def set_host_for_disk_storage
      if %i(local test).include? Rails.application.config.active_storage.service
        ActiveStorage::Current.host = request.base_url
      end
    end

    def require_card
      redirect_to root_path, notice: "カード登録が必要です。" unless current_user&.card?
    end

    def require_subscription
      redirect_to root_path, notice: "サブスクリプション登録が必要です。" unless current_user&.subscription?
    end

    def ensure_page_reload
      session[:reload_page] = true
    end
end
