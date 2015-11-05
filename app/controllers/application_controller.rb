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

  def notify(text, options = {})
    user = current_user || @user
    notify_slack(text, options) if Rails.env.production?
  end

  def notify_slack(text, options = {})
    uri = URI.parse("https://fjord.slack.com/services/hooks/incoming-webhook?token=#{ENV['SLACK_WEBHOOK_TOKEN']}")
    payload = {
      channel: "#learning",
      username: options[:username] || "256interns",
      icon_url: options[:icon_url] || "http://i.gyazo.com/a8afa9d690ff4bbd87459709bbfe8be9.png",
      text: text
    }
    if options[:pretext]
      payload[:fallback] = options[:pretext]
      payload[:pretext] = options[:pretext]
      payload.delete(:text)
    end
    if options[:title]
      payload[:fields] = [{
        title: options[:title],
        value: options[:value],
        short: false
      }]
    end
    logger.info payload
    Net::HTTP.post_form(uri, { payload: payload.to_json })
  end
end
