# frozen_string_literal: true

require 'test_helper'
require 'capybara-playwright-driver'
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

  driven_by :playwright,
            screen_size: [1400, 1400],
            options: {
              browser_type: :chromium,
              chromiumSandbox: false,
              headless: ENV['HEADFUL'] != '1',
              playwright_cli_executable_path: './node_modules/.bin/playwright',
              permissions: %w[clipboard-read clipboard-write]
            }

  setup do
    @original_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :inline
    @original_pjord_product_review = Pjord::ProductReviewAgent.method(:review)
    Pjord::ProductReviewAgent.define_singleton_method(:review) { |_product| '' }
  end

  teardown do
    ActionMailer::Base.deliveries.clear
    Pjord::ProductReviewAgent.define_singleton_method(:review, @original_pjord_product_review)
    ActiveJob::Base.queue_adapter = @original_adapter
  end
end
