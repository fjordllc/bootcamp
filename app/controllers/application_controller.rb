class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :init_user
  before_action :allow_cross_domain_access
  before_action :recent_comments

  def recent_comments
    @activities = PublicActivity::Activity.order(created_at: :desc).where(recipient_id: current_user.id)
  end

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
    response.headers['Access-Control-Allow-Origin'] = "*"
    response.headers['Access-Control-Allow-Methods'] = "*"
  end

  private

  def init_user
    @current_user = User.find(current_user.id) if current_user
  end

  def notify(text, options = {})
    if Rails.env.production?
      icon_url = options[:icon_url] || 'http://i.gyazo.com/a8afa9d690ff4bbd87459709bbfe8be9.png'
      attachments = options[:attachments] || [{}]

      notifier = Slack::Notifier.new ENV['SLACK_WEBHOOK_URL']
      notifier.username = options[:username] || '256interns'
      notifier.ping text, icon_url: icon_url, attachments: attachments
    end
  end
end
