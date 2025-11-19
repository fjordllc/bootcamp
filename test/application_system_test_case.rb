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
