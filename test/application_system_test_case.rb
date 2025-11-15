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
  include ActiveJob::TestHelper
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

  # Rails 7.2: Configure Capybara to use 127.0.0.1 for system tests
  # This ensures redirects work properly
  Capybara.server_host = '127.0.0.1'
  Capybara.always_include_port = true

  if ENV['HEADFUL']
    driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
  else
    driven_by(:selenium, using: :headless_chrome, screen_size: [1400, 1400]) do |driver_option|
      driver_option.add_argument('--no-sandbox')
      driver_option.add_argument('--disable-dev-shm-usage')
      driver_option.add_argument('enable-blink-features=Clipboard')
      driver_option.add_preference('profile.password_manager_leak_detection', false)
    end
  end

  setup do
    # Ensure ActiveStorage is properly configured for system tests
    # Rails 7: ActiveStorage::Current.host= is deprecated, use url_options= instead
    ActiveStorage::Current.url_options = { host: 'localhost', port: 3000, protocol: 'http' }
  end

  teardown do
    ActionMailer::Base.deliveries.clear
    ActiveStorage::Current.url_options = nil

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
