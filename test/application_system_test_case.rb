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
require 'supports/reaction_helper'
require 'supports/clipboard_helper'
require 'supports/announcement_helper'
require 'supports/regular_event_helper'

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
  include ReactionHelper
  include ClipboardHelper
  include AnnouncementHelper
  include RegularEventHelper

  if ENV['HEADFUL']
    driven_by :selenium, using: :chrome
  else
    driven_by(:selenium, using: :headless_chrome) do |driver_option|
      driver_option.add_argument('--no-sandbox')
      driver_option.add_argument('--disable-dev-shm-usage')
      driver_option.add_argument('--disable-gpu')
      driver_option.add_argument('--disable-software-rasterizer')
      driver_option.add_argument('--window-size=1400,1400')
      driver_option.add_argument('enable-blink-features=Clipboard')
      driver_option.add_preference('profile.password_manager_leak_detection', false)

      # Additional stability options for CI
      if ENV['CI']
        driver_option.add_argument('--disable-extensions')
        driver_option.add_argument('--disable-background-networking')
        driver_option.add_argument('--disable-default-apps')
      end
    end
  end

  setup do
    @original_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :inline

    # Set Selenium timeouts to prevent hanging tests in CI
    # Note: implicit_wait is intentionally set to 0 to use Capybara's wait mechanism instead
    if ENV['CI']
      page.driver.browser.manage.timeouts.page_load = 60 # 60 seconds
      page.driver.browser.manage.timeouts.script = 30 # 30 seconds
    end

    CITestLogger.log("[SYSTEM TEST START] #{self.class.name}##{name}")
  end

  teardown do
    CITestLogger.log("[SYSTEM TEST END] #{self.class.name}##{name}")

    ActionMailer::Base.deliveries.clear
    ActiveJob::Base.queue_adapter = @original_adapter
    # Force garbage collection in CI to prevent OOM kills
    GC.start if ENV['CI']
  end
end
