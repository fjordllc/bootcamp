class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :init_user
  before_action :allow_cross_domain_access

  protected

  def not_authenticated
    redirect_to login_path, alert: t('please_sign_in_first')
  end

  def admin_login?
    current_user && current_user.admin?
  end

  def require_admin_login
    unless admin_login?
      redirect_to root_path, alert: t('please_sign_in_as_admin')
    end
  end

  def allow_cross_domain_access
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = '*'
  end

  private

  def init_user
    @current_user = User.find(current_user.id) if current_user
  end

  def notify(text)
    if Rails.env.production?
      open("http://gitter-hubot-fjord-jp.herokuapp.com/hubot/httpd-echo?message=#{text}")
    end
  end
end
