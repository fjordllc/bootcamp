# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/mention_helper'
require 'supports/report_helper'

module Mention
  class ReportsTest < ApplicationSystemTestCase
    include MentionHelper
    include ReportHelper
    setup do
      @delivery_mode = AbstractNotifier.delivery_mode
      AbstractNotifier.delivery_mode = :normal
    end

    teardown do
      AbstractNotifier.delivery_mode = @delivery_mode
    end

    test 'mention from a report' do
      post_mention = lambda { |description|
        create_report('メンション通知が送信されるかのテスト', description, false)
      }

      %w[hatsuno with-hyphen].each do |mention_target_login_name|
        assert exists_unread_mention_notification_after_posting_mention?('kimura', mention_target_login_name, post_mention)
        Report.last.destroy
      end
    end
  end
end
