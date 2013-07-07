class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :init_user

  protected
    def not_authenticated
      redirect_to login_path, alert: t("please_sign_in_first")
    end

    def admin_login?
      current_user and current_user.admin?
    end

    def require_admin_login
      if not admin_login?
        redirect_to root_path, alert: t('please_sign_in_as_admin')
      end
    end

  private
    def init_user
      if current_user
        @current_user = User.find(current_user.id)
      end
    end

    def notify(text)
      Lingman::Updater.update(
        ENV['BOT_ID'],
        ENV['ROOM_ID'],
        ENV['SECRET'],
        text
      ) if Rails.env.production?
    end
end
