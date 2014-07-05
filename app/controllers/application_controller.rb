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
    user = current_user || @user
    if Rails.env.production?
      notify_gitter(text)
      notify_sqwiggle(text) if user.nexway?
    end
  end

  def notify_gitter(text)
    text = URI.encode(text)
    uri = URI.parse("http://gitter-hubot-fjord-jp.herokuapp.com/hubot/httpd-echo?message=#{text}")
    Net::HTTP.get(uri)
  end

  def notify_sqwiggle(text)
    client = Sqwiggle.client(ENV['SQWIGGLE_API_KEY'])
    message = client.messages.new
    message.room_id = client.rooms.find('nexwaytraining').id
    message.text = text
    message.save!
  end
end
