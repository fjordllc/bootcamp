require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  test "should be valid" do
    assert notifications(:notification_commented).valid?
    assert notifications(:notification_checked).valid?
    assert notifications(:notification_mention).valid?
    assert notifications(:notification_read).valid?
  end
end
