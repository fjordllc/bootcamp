# frozen_string_literal: true

require "test_helper"

class InnerNotificationTest < ActiveSupport::TestCase
  test "should be valid" do
    assert inner_notifications(:notification_commented).valid?
    assert inner_notifications(:notification_checked).valid?
    assert inner_notifications(:notification_mentioned).valid?
    assert inner_notifications(:notification_read).valid?
  end
end
