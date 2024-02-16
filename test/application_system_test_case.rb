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
  if ENV['HEADFULL']
    driven_by(:selenium, using: :chrome) do |driver_option|
      options = driver_option.args
      options << '--lang=ja'
      options << '--user-agent=ja-JP'
      driver_option.args = options
    end
  else
    driven_by(:selenium, using: :headless_chrome) do |driver_option|
      options = driver_option.args
      options << '--headless=old'
      options << '--no-sandbox'
      options << '--disable-dev-shm-usage'
      options << '--lang=ja'
      options << '--user-agent=ja-JP'
      driver_option.args = options
    end
  end

  teardown do
    ActionMailer::Base.deliveries.clear
  end
end
