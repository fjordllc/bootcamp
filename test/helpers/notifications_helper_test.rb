# frozen_string_literal: true

require 'test_helper'

class NotificationsHelperTest < ActionView::TestCase
  test 'notification_count' do
    def current_user
      users(:hatsuno)
    end

    assert_equal 2, notification_count(:all)
    assert_equal 0, notification_count(:announcement)
    assert_equal 0, notification_count(:mention)
    assert_equal 0, notification_count(:comment)
    assert_equal 0, notification_count(:check)
    assert_equal 0, notification_count(:watching)
    assert_equal 0, notification_count(:following_report)
  end
end
