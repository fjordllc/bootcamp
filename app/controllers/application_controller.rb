class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :init_user
  before_action :allow_cross_domain_access
  helper_method :admin_login?

  protected
    def not_authenticated
      redirect_to root_path, alert: t("please_sign_in_first")
    end

    def admin_login?
      current_user && current_user.admin?
    end

    def require_admin_login
      unless admin_login?
        redirect_to root_path, alert: t("please_sign_in_as_admin")
      end
    end

    def allow_cross_domain_access
      response.headers["Access-Control-Allow-Origin"] = "*"
      response.headers["Access-Control-Allow-Methods"] = "*"
    end

  private
    class NoOpHTTPClient
      def self.post uri, params={}
        Rails.logger.info "Notify\nwebhook_uri:#{uri}\nparams:#{params.to_s}"
      end
    end
    def init_user
      @current_user = User.find(current_user.id) if current_user
    end

    def notify(text, options = {})

      icon_url = options[:icon_url] || "http://i.gyazo.com/a8afa9d690ff4bbd87459709bbfe8be9.png"
      attachments = options[:attachments] || [{}]
      username = options[:username] || "Bootcamp"
      if Rails.env.production?
        notifier = Slack::Notifier.new ENV["SLACK_WEBHOOK_URL"], username: username
      else
        notifier = Slack::Notifier.new ENV["SLACK_WEBHOOK_URL"], username: username, http_client: NoOpHTTPClient
      end
        notifier.ping text, icon_url: icon_url, attachments: attachments
    
    end
end
