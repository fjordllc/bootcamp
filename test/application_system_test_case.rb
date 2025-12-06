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

# Counter for browser restart in CI to prevent memory buildup
module BrowserRestartCounter
  class << self
    attr_accessor :test_count

    def increment
      self.test_count ||= 0
      self.test_count += 1
    end

    def should_restart?(threshold = 15)
      test_count && (test_count % threshold).zero?
    end

    def restart_browser!
      return unless Capybara.current_session.driver.browser

      Capybara.current_session.driver.quit
      GC.start(full_mark: true, immediate_sweep: true)
    end
  end
end

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
      driver_option.add_argument('enable-blink-features=Clipboard')
      driver_option.add_preference('profile.password_manager_leak_detection', false)
    end
  end

  setup do
    @original_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :inline
  end

  teardown do
    ActionMailer::Base.deliveries.clear
    ActiveJob::Base.queue_adapter = @original_adapter

    # Restart browser periodically in CI to prevent memory buildup
    if ENV['CI']
      BrowserRestartCounter.increment
      BrowserRestartCounter.restart_browser! if BrowserRestartCounter.should_restart?(15)
    end
  end
end
