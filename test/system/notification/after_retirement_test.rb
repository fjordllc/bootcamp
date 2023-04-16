# frozen_string_literal: true

require 'application_system_test_case'

class Notification::AfterRetirementTest < ApplicationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
    @notice_text = 'komagataさんから回答がありました。'
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end
end
