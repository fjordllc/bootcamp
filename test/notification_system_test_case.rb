# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/mock_helper'

class NotificationSystemTestCase < ApplicationSystemTestCase
  include MockHelper

  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end
end
