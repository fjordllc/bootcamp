# frozen_string_literal: true

require 'test_helper'
require 'supports/login_helper'
require 'supports/test_auth_helper'
require 'supports/stripe_helper'
require 'supports/notification_helper'
require 'supports/report_helper'
require 'supports/comment_helper'
require 'supports/tag_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include LoginHelper
  include TestAuthHelper
  include StripeHelper
  include NotificationHelper
  include ReportHelper
  include CommentHelper
  include TagHelper

  if ENV['HEADED']
    driven_by :selenium, using: :chrome
  else
    driven_by(:selenium, using: :headless_chrome) do |driver_option|
      driver_option.add_argument('--no-sandbox')
      driver_option.add_argument('--disable-dev-shm-usage')
    end
  end

  teardown do
    ActionMailer::Base.deliveries.clear
  end

  def vcr_options
    {
      record: :once,
      match_requests_on: [
        :method,
        VCR.request_matchers.uri_without_param(:source)
      ]
    }
  end
end
