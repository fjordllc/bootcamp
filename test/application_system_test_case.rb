# frozen_string_literal: true

require 'test_helper'
require 'supports/login_helper'
require 'supports/test_auth_helper'
require 'supports/stripe_helper'
require 'supports/notification_helper'
require 'supports/report_helper'
require 'supports/comment_helper'
require 'supports/tag_helper'
require 'supports/mock_env_helper'
require 'supports/article_helper'
require 'supports/javascript_helper'
require 'supports/product_helper'
require 'supports/avatar_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include LoginHelper
  include TestAuthHelper
  include StripeHelper
  include NotificationHelper
  include ReportHelper
  include CommentHelper
  include TagHelper
  include MockEnvHelper
  include ArticleHelper
  include JavascriptHelper
  include ProductHelper
  include AvatarHelper

  if ENV['HEADFUL']
    driven_by :selenium, using: :chrome
  else
    driven_by(:selenium, using: :headless_chrome) do |driver_option|
      driver_option.add_argument('--no-sandbox')
      driver_option.add_argument('--disable-dev-shm-usage')
      driver_option.add_argument('--disable-gpu')
      driver_option.add_argument('--disable-web-security')
      driver_option.add_argument('--disable-features=VizDisplayCompositor')
      driver_option.add_argument('--disable-background-timer-throttling')
      driver_option.add_argument('--disable-backgrounding-occluded-windows')
      driver_option.add_argument('--disable-renderer-backgrounding')
      driver_option.add_argument('--disable-extensions')
      driver_option.add_argument('--disable-plugins')
      driver_option.add_argument('--disable-ipc-flooding-protection')
      driver_option.add_argument('--window-size=1400,900')
      driver_option.add_argument('--enable-logging')
      driver_option.add_argument('--log-level=0')
      driver_option.add_argument('enable-blink-features=Clipboard')

      # CI specific options
      if ENV['CI']
        driver_option.add_argument('--remote-debugging-port=9222')
        driver_option.add_argument('--disable-features=TranslateUI')
        driver_option.add_argument('--disable-background-networking')
        driver_option.add_argument('--enable-features=NetworkService,NetworkServiceLogging')
      end

      # Enable JavaScript console logging for debugging
      driver_option.add_preference(:loggingPrefs, { browser: 'ALL' })
    end
  end

  setup do
    # Ensure URL options are properly configured for system tests
    host = ENV['CI'] ? '127.0.0.1' : 'localhost'
    port = Capybara.server_port || 3000

    Rails.application.routes.default_url_options[:host] = host
    Rails.application.routes.default_url_options[:port] = port
    Rails.application.config.active_storage.default_url_options = { host:, port: }

    # Configure Capybara for CI environment
    if ENV['CI']
      Capybara.server_host = '127.0.0.1'
      Capybara.app_host = "http://127.0.0.1:#{port}"
    end
  end

  teardown do
    ActionMailer::Base.deliveries.clear
    Rails.application.routes.default_url_options.delete(:host)
    Rails.application.routes.default_url_options.delete(:port)

    # Clean up any uploaded test files
    if defined?(ActiveStorage::Blob)
      begin
        ActiveStorage::Blob.unattached.where('created_at < ?', 1.hour.ago).find_each(&:purge)
      rescue StandardError
        # Ignore cleanup errors in tests
      end
    end
  end
end
