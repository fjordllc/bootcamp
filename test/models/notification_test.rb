require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  test "should be valid" do
    assert notifications(:notification_1).valid?
  end
end
