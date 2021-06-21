# frozen_string_literal: true

require 'test_helper'
require 'supports/login_helper'
require 'supports/stripe_helper'
require 'supports/notification_helper'
require 'supports/report_helper'
require 'supports/comment_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include LoginHelper
  include StripeHelper
  include NotificationHelper
  include ReportHelper
  include CommentHelper

  VUEJS_WAIT_SECOND = (ENV['VUEJS_WAIT_SECOND'] || 2).to_i

  if ENV['HEADED']
    driven_by :selenium, using: :chrome
  else
    driven_by :selenium, using: :headless_chrome
  end

  def wait_for_vuejs
    # https://bootcamp.fjord.jp/questions/468 に書いた理由により、やむを得ずsleepする
    sleep VUEJS_WAIT_SECOND
  end
end
